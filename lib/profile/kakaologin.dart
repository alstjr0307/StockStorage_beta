import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';

import '../realhome.dart';

class KakaoLogin extends StatefulWidget {
  @override
  _KakaoLoginState createState() => _KakaoLoginState();
}

class _KakaoLoginState extends State {
  bool _isKakaoTalkInstalled = false;

  @override
  void initState() {
    _initKakaoTalkInstalled();
    super.initState();
  }

  _initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();
    print('kakao Install : ' + installed.toString());

    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }

  _issueAccessToken(String authCode) async {
    try {
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      print('a${token}');
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => LoginResult(),
      ));
    } catch (e) {
      print(e.toString());
    }
  }

  _loginWithKakao() async {
    print('3');
    try{
      var code = await AuthCodeClient.instance.request();
      await _issueAccessToken(code);
      print(code);
    } catch (e) {
      print('카카오로그인' + e.toString());
    }
  }

  _loginWithTalk() async {
    try{
      var code = await AuthCodeClient.instance.requestWithTalk();
      await _issueAccessToken(code);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('kakao login test'),
        ),
        body: Center(
            child: InkWell(
              onTap: _isKakaoTalkInstalled ? _loginWithTalk : _loginWithKakao,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.yellow
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble, color: Colors.black54),
                      SizedBox(width: 10,),
                      Text(
                        '카카오계정 로그인',
                        style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w900,
                            fontSize: 20
                        ),
                      ),
                    ],
                  )
              ),
            )
        )
    );
  }
}

class LoginResult extends StatefulWidget {
  @override
  _LoginResultState createState() => _LoginResultState();
}

class _LoginResultState extends State {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initTexts();
  }

  _initTexts() async {
    final User user = await UserApi.instance.me();

    print(
        "=========================[kakao account]=================================");
    print(user.kakaoAccount.toString());

    print(
        "=========================[kakao account]=================================");

    setState(() {
      _accountEmail = user.kakaoAccount.email;
      _ageRange = user.kakaoAccount.profile.nickname.toString();
      _gender = user.kakaoAccount.gender.toString();
    });
  }

  String _accountEmail = 'None';
  String _ageRange = 'None';
  String _gender = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text(_accountEmail),
              Text(_ageRange),
              Text(_gender),
            ],
          ),
        ),
      ),
    );
  }
}