import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class storageDetail extends StatefulWidget {
  final int index;

  const storageDetail({Key key, this.index}) : super(key: key); //index = 게시물 번호

  @override
  _storageDetailState createState() => _storageDetailState();
}

class _storageDetailState extends State<storageDetail> {
  //전체게시물 데이터 수집(restapi)
  Map content;
  Map commentmap;
  Map postlistmap;
  var comment;
  var postlist;

  Future getData() async {
    print('3');
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final response = await http.get(
        Uri.http('13.125.62.90', "api/v1/BlogPosts/${widget.index}/"),
        headers: {"Authorization": "Token ${token}"}); //게시물 가져오기
    content = jsonDecode(utf8.decode(response.bodyBytes));
    print(' zjs${content['id']}');
    var comresponse = await http.get(
        Uri.http('13.125.62.90', 'api/v1/BlogPostcomment',
            {'blogpost_connected': "${content['id']}"}),
        headers: {"Authorization": "Token ${token}"}); //게시물 댓글 가져오기
    print('1');
    commentmap = jsonDecode(utf8.decode(comresponse.bodyBytes));
    comment = commentmap['results'];
    print(comment);

    print('댓끝');
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

            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Html(
                      data: content['content'],
                      onLinkTap: (url) {
                        print("Opening $url...");
                      },
                    ),
                    scrollDirection: Axis.vertical,
                  ),
                ),
                Column(
                  children: [
                    for (var i in comment)
                      Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    child: Text(
                                  i['user'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Text(
                                  i['content'],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (comment.length < 1) Text('댓글이 없습니다'),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
