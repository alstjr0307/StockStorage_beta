import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'allDetail.dart';
import 'package:flutter_app/Navigatior/postTab.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController= TextEditingController();
  String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 작성'),
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Text('제목'),
                TextField(
                  controller: titleController,
                  keyboardType: TextInputType.text,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "제목을 입력해주세요",
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                Text('내용'),
                TextField(
                  controller: contentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(hintText: "내용을 입력해주세요"),
                ),
              ],
            ),
          ),
          Container(
              child: Row(
            children: [
              Text('게시판'),
              Expanded(
                child: Container(
                  child: DropdownButton(
                    hint: category == null
                        ? Text('Dropdown')
                        : Text(
                            category,
                            style: TextStyle(color: Colors.blue),
                          ),
                    isExpanded: true,
                    iconSize: 30.0,
                    style: TextStyle(color: Colors.blue),
                    items: ['국내주식', '해외주식', '자유게시판'].map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      setState(
                        () {
                          category = val;
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          )),
          TextButton(
            onPressed: () async {
              print(titleController.text);
              await addPost(titleController.text, contentController.text, category);
            },
            child: Text('ss'),
          )
        ],
      ),
    );
  }

  Future<void> addPost(String title, String content, String category) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    var formatter = new DateFormat('yyyy-MM-dd H:m');
    print('하는중');
    var now = new DateTime.now();
    var str = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
    print(str);
    print(now);
    if (category == "국내주식") {
      category = "D";
    } else if (category == "해외주식")
      category = "F";
    else {
      category = "R";
    }
    final responseerw = await http.post(
        Uri.http('13.125.62.90', "api/v1/BlogPosts/"),
        headers: {
          "Authorization": "Token ${token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          <String, dynamic>{
            "title": title,
            "content": content,
            "slug": "none",
            "description": "none",
            "create_dt": str,
            "modify_dt": str,
            "category": category,
            "owner" : sharedPreferences.getInt('userID')
          },
        ));
    print('종료');
    print(responseerw.body);
    setState(() {});
  }
  dynamic myEncode(dynamic item) {
    if(item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}
