import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/profile/changenickname.dart';
import 'package:flutter_app/search/writerpost.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'changepassword.dart';

class Profile extends StatelessWidget {
  final dio = new Dio();

  Future<Map> getProfile() async {
    print('12');
    var sharedPreferences = await SharedPreferences.getInstance();
    print('13');
    var token = sharedPreferences.getString("token");
    var userid = sharedPreferences.getInt("userID");
    print('2342');
    print(token);
    print('ww${userid.toString()}');
    var profileurl =
        'http://13.125.62.90/api/v1/AuthUser/${userid.toString()}/';
    print(profileurl);
    final responseall = await dio.get(profileurl,
        options: Options(headers: {"Authorization": "Token ${token}"}));
    print('exit');
    Map profile = responseall.data;

    return profile;
  }

  @override
  Widget build(BuildContext context) {
    print('1');
    return FutureBuilder(
        future: getProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Scaffold(
              body: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.deepPurple, Colors.grey])),
                      child: Container(
                        width: double.infinity,
                        height: 350.0,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/photos/example.PNG'),
                                radius: 50.0,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                snapshot.data['first_name'],
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.white,
                                elevation: 5.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 22.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WriterPost(userID :snapshot.data['id'], nickname: snapshot.data['first_name'])));
                                          },
                                          child: Column(
                                            children: [
                                              Text(
                                                "게시물",
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                snapshot.data['post']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.pinkAccent,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              "댓글",
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Text(
                                              snapshot.data['comment']
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.pinkAccent,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    width: 300.00,
                    child: Column(
                      children: [
                        RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChangePassword()));
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
                            elevation: 0.0,
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [Colors.pink, Colors.pinkAccent]),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: 300.0, minHeight: 50.0),
                                alignment: Alignment.center,
                                child: Text(
                                  "비밀번호 변경",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChangeNickname()));
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
                            elevation: 0.0,
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [Colors.pink, Colors.pinkAccent]),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: 300.0, minHeight: 50.0),
                                alignment: Alignment.center,
                                child: Text(
                                  "닉네임 변경",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          else {
            return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              )),
            );
          }
        });
  }
}
