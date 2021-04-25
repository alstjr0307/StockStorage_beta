import 'package:flutter/material.dart';
import 'package:flutter_app/all/allDetail.dart';
import 'package:flutter_app/loginpage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'model.dart';
import 'all/allpost.dart';
import 'home.dart';
import 'loginpage.dart';
import 'realhome.dart';
import 'Navigatior/Storage/storage.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //7
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),

    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  SharedPreferences sharedPreferences;
  @override
  void initState(){
    super.initState();
    checkLoginStatus();
  }
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") ==null){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Code Land", style: TextStyle(color: Colors.white)),
            actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text("Log out", style: TextStyle(color: Colors.white)),
          )
        ]));
  }
}
