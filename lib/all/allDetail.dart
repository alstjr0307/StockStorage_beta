import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class allDetail extends StatefulWidget {
  final int index;

  const allDetail({Key key, this.index}) : super(key: key); //index = 게시물 번호

  @override
  _allDetailState createState() => _allDetailState();
}

class _allDetailState extends State<allDetail> {
  //전체게시물 데이터 수집(restapi)
  Map content;
  Map commentmap;
  Map postlistmap;
  var comment;
  var postlist;

  Future getData() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final response = await http.get(
        Uri.http('13.125.62.90', "api/v1/BlogPosts/${widget.index}/"),
        headers: {"Authorization": "Token ${token}"}); //게시물 가져오기
    content = jsonDecode(utf8.decode(response.bodyBytes));
    content['time'] =
        DateFormat("M월dd일 H:m").format(DateTime.parse(content['create_dt']));

    return content;
  }

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
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
              title: Text(content['title']),
              centerTitle: true,
            ),
            //목록으로 버튼
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.list),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            body: ListView(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 3, color: Colors.grey),
                            borderRadius: BorderRadius.only(

                                bottomLeft: const Radius.circular(20.0),
                                bottomRight: const Radius.circular(20.0))),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 10),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    leading:
                                        Icon(Icons.person_outline, size: 40),
                                    title: Text(content['writer']),
                                    subtitle: Row(
                                      children: [
                                        Text(content['time']),
                                        SizedBox(
                                          width: 10,
                                          height: 20,
                                        ),
                                        Icon(Icons.thumb_up,
                                            size: 13, color: Colors.red),
                                        Text(content['likes'].toString(),
                                            style:
                                                TextStyle(color: Colors.red)),
                                        SizedBox(width: 10),
                                        Text(content[''].toString(),
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.thumb_up,
                                      size: 15,
                                      color: Colors.redAccent,
                                    ),
                                    label: Text('공감',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.redAccent)),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                content['title'],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Html(
                          data: content['content'],
                          onLinkTap: (url) {
                            print("Opening $url...");
                          },
                        ),
                        scrollDirection: Axis.vertical,
                      ),
                      Column(
                        children: [
                          for (var i in content['blogpostcomment_set'])
                            Card(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          child: Text(
                                        i['user'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      Text(
                                        i['content'],
                                      ),
                                    ],
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
          );
        }
      },
    );
  }
}
