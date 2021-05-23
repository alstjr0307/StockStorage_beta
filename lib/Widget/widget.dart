import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

Widget likeText(bool like) {
  if (like) {
    return Text('추천취소',
        style: TextStyle(fontSize: 13, color: Colors.redAccent));
  } else {
    return Text('추천', style: TextStyle(fontSize: 13, color: Colors.redAccent));
  }
}

Widget contentText(String content) {
  return SingleChildScrollView(
    child: Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Colors.black26, width: 1, style: BorderStyle.solid))),
      child: Html(
        data: content,

      ),
    ),
    scrollDirection: Axis.vertical,
  );
}

Widget titleText(String title, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
    child: Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}

Widget commentList(List comment_set, int count, int userId, String token) {
  for (var i in comment_set) {
    i['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(i['created']));
  }
  return Column(
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
            Text(' (${count})'),
          ],
        ),
      ),
      for (var i in comment_set)
        Container(
          padding: EdgeInsets.all(3),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 0.1))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      if (i['writer'] == userId)
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              print(i['id']);
                              print(token);
                              var response = await http.delete(
                                Uri.http('13.125.62.90',
                                    'api/v1/BlogPostcomment/${i['id']}/'),
                                headers: {
                                  "Authorization": "Token $token",
                                  "Content-Type": "application/json"
                                },
                              );
                              print(response.bodyBytes);
                            }),
                      Text(i['time'],
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
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
  );
}

Future<Map> getPostData(int postId, Map content) async {
  var sharedPreferences = await SharedPreferences.getInstance();
  var token = sharedPreferences.getString("token");

  print( '포스트 $postId');
  final response = await http.get(
    Uri.http('13.125.62.90', "api/v1/BlogPosts/${postId}/"),
  ); //게시물 가져오기
  print(response.statusCode);
  print('포스트 ${postId}');
  if (response.statusCode == 200) {
    // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
    content = jsonDecode(utf8.decode(response.bodyBytes));
    content['time'] =
        DateFormat("M월dd일 H:m").format(DateTime.parse(content['create_dt']));
    if (token != null) {
      content['id'] = sharedPreferences.getInt("userID");
      content['token'] = token;
    }
    for (var i in content['blogpostcomment_set']) {
      i['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(i['created']));
    }

    return content;
  } else {
    // 만약 응답이 OK가 아니면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }


}
