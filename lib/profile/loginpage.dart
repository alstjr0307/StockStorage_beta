
import 'package:flutter/material.dart';
import 'package:flutter_app/profile/kakaologin.dart';
import 'package:flutter_app/profile/signup.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/all.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../realhome.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String msg = '.';

  Widget errormsg = Container();

  @override
  Widget build(BuildContext context) {

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
                    signupSection(),
                    goHome(),
                    TextButton(
                      child: Text('카카오계정 로그인'),
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KakaoLogin()));

                      },
                    )
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
      var userresponse = await http.get(
          Uri.http("13.125.62.90", "api/v2/auth/users/me"),
          headers: {"Authorization": "Token ${token}"});
      var user = jsonDecode(utf8.decode(userresponse.bodyBytes));
      setState(() {
        _isLoading = false;
        sharedPreferences.setString("token", jsonData['auth_token']);
        sharedPreferences.setString("nickname", user['first_name']);
        sharedPreferences.setInt('userID', user['id']);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => RealHome()),
            (Route<dynamic> route) => false);
      });
    }
    if (response.statusCode == 400) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      var message = [];

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
                  json["non_field_errors"][0],
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
          child: Text("로그인", style: TextStyle(color: Colors.white70)),
        ));
  }

  Container goHome() {
    return Container(
      child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('비회원으로 계속하기')),
    );
  }

  Container signupSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 40.0,
        margin: EdgeInsets.only(top: 30.0),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: RaisedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => SignUp()),
            );
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
      child: Column(children: <Widget>[
        txtUsername('Username', Icons.person_outline),
        SizedBox(height: 30.0),
        txtPassword("Password", Icons.lock),
        SizedBox(height: 30.0),
        errormsg,
      ]),
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
      obscureText: true,
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
      child: Text('주식저장소 로그인', style: TextStyle(color: Colors.white)),
    );
  }
}
