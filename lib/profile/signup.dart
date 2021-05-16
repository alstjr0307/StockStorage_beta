import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

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

    var response = await http
        .post(Uri.http("13.125.62.90", "api/v2/auth/users/"), body: data);

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
                content: Text("환영합니다 $username 님, 이메일 인증을 받아주세요"),
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
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      var message = [];
      json.forEach((final String key, final value) {
        print(value);
        if (json[key][0] == "A user with that username already exists.") {
          print(key);
          json["$key"][0] = "아이디가 이미 존재합니다";
        }
        if (json[key][0] =="This field may not be blank." && key=="password") {
          json[key][0] = "비밀번호를 입력해주세요";
        }
      });

      print(json['email']);
      print(json);
      setState(() {
        _isLoading = false;
        errormsg = Card(
          color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var value in json.values)
                ListTile(
                  minVerticalPadding: 0,
                  leading: Icon(Icons.error, size: 50),
                  title: Text(
                    value[0],
                    style: TextStyle(color: Colors.white, fontSize: 15),
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
                        '주식저장소 회원가입',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      )),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      maxLength: 15,

                      controller: usernameController,
                      inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '(15자이내 영문+숫자)',
                        labelText: '아이디',
                      ),
                    ),
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

                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      maxLength: 6,
                      inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣]")),],
                      controller: nicknameController,
                      decoration: InputDecoration(
                        hintText: '(한글, 영어, 숫자 가능, 6자 이내)',

                        border: OutlineInputBorder(),
                        labelText: '닉네임',
                      ),
                    ),
                  ),

                  Container(
                    height: 40,
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
                        }
                          else
                        {
                          errormsg = Card(
                            color: Colors.red,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.error, size: 50),
                                  title: Text(
                                    ' 비밀번호가 일치하지 않습니다',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
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
