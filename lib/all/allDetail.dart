import 'dart:ui';

import 'package:beauty_textfield/beauty_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/Widget/widget.dart';

class Likes {
  final int id;
  final int post;
  final int user;

  Likes({this.id, this.post, this.user});

  factory Likes.fromJson(Map<String, dynamic> json) {
    return Likes(id: json['id'], post: json['post'], user: json['user']);
  }
}

class allDetail extends StatefulWidget {
  final int index;

  const allDetail({Key key, this.index}) : super(key: key); //index = 게시물 번호

  @override
  _allDetailState createState() => _allDetailState();
}

class _allDetailState extends State<allDetail> {
  final TextEditingController commentController = TextEditingController();
  Map content;
  ScrollController _sc = new ScrollController();

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  //전체게시물 데이터 수집(restapi)
  Map commentmap;
  Map postlistmap;
  var comment;
  var postlist;
  bool whether_like = false;

  //백버튼 작용
  @override
  void initState() {
    super.initState();

    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context); // Do some stuff.
    return true;
  }

  Future<void> postComment(String comment) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    var formatter = new DateFormat('yyyy-MM-dd H:m');
    var now = new DateTime.now();
    final likeresponse = await http.post(
        Uri.http('13.125.62.90', "api/v1/BlogPostcomment/"),
        headers: {
          "Authorization": "Token ${token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(<String, dynamic>{
          'blogpost_connected': widget.index.toInt(),
          'writer': sharedPreferences.getInt("userID"),
          'created': formatter.format(now),
          'updated': formatter.format(now),
          'content': comment
        }));
    setState(() {});
  }

  Future<void> doLikes() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    print(sharedPreferences.getString("token"));
    print(widget.index);
    print(sharedPreferences.getInt("userID"));
    final likeresponse = await http.post(
        Uri.http('13.125.62.90', "api/v1/BlogPostsLikes/"),
        headers: {
          "Authorization": "Token ${token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(<String, int>{
          'post': widget.index.toInt(),
          'user': sharedPreferences.getInt("userID"),
        }));
    whether_like = true;

    if (likeresponse.statusCode == 400) {
      final likeresponsee = await http.get(
        Uri.http('13.125.62.90', "api/v1/BlogPostsLikes/", {
          "user": "${sharedPreferences.getInt("userID")}",
          "post": "${widget.index}"
        }),
        headers: {
          "Authorization": "Token ${token}",
          "Content-Type": "application/json"
        },
      );

      var a = jsonDecode(likeresponsee.body);
      print('body : ${a}');
      print(a[0]['id']);

      final likeresponseee = await http.delete(
        Uri.http('13.125.62.90', "api/v1/BlogPostsLikes/${a[0]['id']}/"),
        headers: {
          "Authorization": "Token ${token}",
          "Content-Type": "application/json"
        },
      );
      print(likeresponseee);
      setState(() {
        whether_like = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: FutureBuilder(
        future: getPostData(widget.index, content),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              )),
            );
          else {
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(snapshot.data['title']),
                    if (snapshot.data['id'] == snapshot.data['owner'])
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  print(snapshot.data['token']);
                                  return AlertDialog(
                                    title: Text('삭제'),
                                    content: Text('게시물 삭제하시겠습니까?'),
                                    actions: [
                                      FlatButton(
                                        onPressed: () async {
                                          var response = await http.delete(
                                            Uri.http('13.125.62.90',
                                                'api/v1/BlogPosts/${snapshot.data['id']}/'),
                                            headers: {
                                              "Authorization":
                                                  "Token ${snapshot.data['token']}",
                                              "Content-Type": "application/json"
                                            },
                                          );
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('예'),
                                      ),
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('아니오')),
                                    ],
                                  );
                                });
                          })
                  ],
                ),
                centerTitle: true,
              ),
              //목록으로 버튼

              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                //제목&작성자
                                margin: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 3, color: Colors.black38),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(0),
                                            leading: Icon(Icons.person_outline,
                                                size: 40),
                                            title:
                                                Text(snapshot.data['writer']),
                                            subtitle: Row(
                                              children: [
                                                Text(snapshot.data['time']),
                                                SizedBox(
                                                  width: 10,
                                                  height: 20,
                                                ),
                                                Icon(Icons.thumb_up,
                                                    size: 13,
                                                    color: Colors.red),
                                                Text(
                                                    snapshot.data['likes']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                SizedBox(width: 10),
                                                Icon(Icons.comment,
                                                    size: 13,
                                                    color: Colors.red),
                                                Text(
                                                    snapshot.data['comment']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        //추천버튼
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              await doLikes();
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              Icons.thumb_up,
                                              size: 15,
                                              color: Colors.redAccent,
                                            ),
                                            label: likeText(whether_like),
                                          ),
                                        ),
                                      ],
                                    ),
                                    titleText(snapshot.data['title'], context),
                                  ],
                                ),
                              ),
                              contentText(snapshot.data['content']),
                              //댓글 리스트
                              Column(
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          width: 5,
                                        ),
                                        Icon(Icons.comment, color: Colors.red),
                                        Text(
                                          '댓글',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        Text(
                                            '(${snapshot.data['comment'].toString()})'),
                                      ],
                                    ),
                                  ),
                                  for (var i in snapshot
                                      .data['blogpostcomment_set']) //댓글달기
                                    Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(width: 0.1))),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Icon(Icons.person_outline),
                                                Text(
                                                  i['user'],
                                                  style: TextStyle(),
                                                ),
                                              ]),
                                              Row(
                                                children: [
                                                  if (i['writer'] ==
                                                      snapshot.data['id'])
                                                    IconButton(
                                                        padding: EdgeInsets.zero,
                                                        constraints: BoxConstraints(),
                                                        //댓글삭제버튼
                                                        icon: Icon(
                                                          Icons.delete_sharp,
                                                          size: 19,
                                                        ),
                                                        onPressed: () async {
                                                          await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      '삭제'),
                                                                  content: Text(
                                                                      '댓글을 삭제하시겠습니까?'),
                                                                  actions: [
                                                                    FlatButton(
                                                                      onPressed:
                                                                          () async {
                                                                        var response =
                                                                            await http.delete(
                                                                          Uri.http(
                                                                              '13.125.62.90',
                                                                              'api/v1/BlogPostcomment/${i['id']}/'),
                                                                          headers: {
                                                                            "Authorization":
                                                                                "Token ${snapshot.data['token']}",
                                                                            "Content-Type":
                                                                                "application/json"
                                                                          },
                                                                        );
                                                                        setState(
                                                                            () {});
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                          '예'),
                                                                    ),
                                                                    FlatButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            '아니오')),
                                                                  ],
                                                                );
                                                              });
                                                        }),
                                                  Text(i['time'],
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10)),
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              i['content'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //댓글달기
                    child: Column(
                      children: [
                        new Padding(padding: EdgeInsets.only(top: 5.0)),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: TextField(
                                  controller: commentController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    hintText: "댓글을 입력해주세요",
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        postComment(commentController.text);
                                        commentController.clear();
                                        currentFocus.unfocus();

                                        _sc.animateTo(
                                          _sc.position.maxScrollExtent,
                                          duration:
                                              const Duration(milliseconds: 10),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      icon: Icon(Icons.send),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
