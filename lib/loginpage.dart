import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String msg = '';
  @override
  Widget build(BuildContext context) {
    print('1');
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.teal,
              ],
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    headerSection(),
                    textSection(),
                    buttonSection(),
                  ],
                )),
    );
  }

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  sign(String username, password) async {
    Map data = {
      "username": username,
      "password": password,
    };
    print('2');
    var jsonData;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print('123');
    var response = await http
        .post(Uri.http("13.125.62.90", "api/v2/auth/token/login/"), body: data);
    if (response.statusCode == 200) {
      print('1');
      jsonData = json.decode(response.body);
      var token = jsonData['auth_token'];
      var userresponse = await http.get(Uri.http("13.125.62.90", "api/v2/auth/users/me"), headers: {"Authorization" : "Token ${token}"});
      var user = jsonDecode(utf8.decode(userresponse.bodyBytes));
      setState(() {
        _isLoading = false;
        sharedPreferences.setString("token", jsonData['auth_token']);
        sharedPreferences.setString("nickname", user['first_name']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            (Route<dynamic> route) => false);
      });
    }
    if (response.statusCode == 400) {
      setState(() {
        _isLoading = false;
        msg='잘못된 로그인 정보';
      });

    }
      else

      print(response.body);
  }

  Container buttonSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 40.0,
        margin: EdgeInsets.only(top: 30.0),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: RaisedButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            sign(usernameController.text, passwordController.text);
          },
          color: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text("회원가입", style: TextStyle(color: Colors.white70)),
        ));
  }

  Container textSection() {
    print('4');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          txtUsername('Username', Icons.email),
          SizedBox(height: 30.0),
          txtPassword("Password", Icons.lock),
          SizedBox(height:30.0),
          Text(msg),
        ],
      ),
    );
  }

  TextFormField txtUsername(String title, IconData icon) {
    print('5');
    return TextFormField(
      controller: usernameController,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icon),
      ),
    );
  }

  TextFormField txtPassword(String title, IconData icon) {
    print('6');
    return TextFormField(
      controller: passwordController,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icon),
      ),
    );
  }

  Container headerSection() {
    print('3');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text('Code Land', style: TextStyle(color: Colors.white)),
    );
  }
}
