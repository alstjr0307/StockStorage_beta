import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/realhome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<SignUp> {
  TextEditingController nicknameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  Widget errormsg = Container();

  sign(String email, username, password, nickname) async {
    Map data = {
      "email": email,
      "username": username,
      "password": password,
      "first_name": nickname
    };

    var response = await http.post(Uri.http("13.125.62.90", "api/v2/auth/users/"),
        body: data);

    print(response.statusCode);
    if (response.statusCode == 201) {
      print('1');

      print('제대로 됨');
      setState(() {
        _isLoading = false;

        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('회원가입 성공'),
                content: Text("환영합니다 $username 님"),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('확인')),
                ],
              );
            });
      });
    }
    if (response.statusCode == 400) {
      print(response.body);
      setState(() {
        _isLoading = false;
        errormsg = Card(
          color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.error, size: 50),
                title: Text(
                  '잘못된 입력입니다',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      });
    } else
      print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      )),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '아이디',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '이메일',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '비밀번호',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: passwordConfirmController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '비밀번호 확인',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: nicknameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '닉네임',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text(
                        '제출',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (passwordController.text ==
                            passwordConfirmController.text) {
                          setState(() {
                            _isLoading = true;
                          });
                          sign(emailController.text, usernameController.text,
                              passwordController.text, nicknameController.text);
                        } else {
                          errormsg = Card(
                            color: Colors.red,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.error, size: 50),
                                  title: Text(
                                    '새 비밀번호가 일치하지 않습니다',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  errormsg,
                ],
              ),
            ),
    );
  }
}
