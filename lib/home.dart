import 'package:flutter/material.dart';

import 'all/allpost.dart';
import 'domestic/domesticPost.dart';
import 'foreign/ForeignPost.dart';
import 'free/freePost.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'Navigatior/postTab.dart';

int index = 0;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomePage> {

  @override
  bool get wantKeepAlive => true;
  Widget page;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Navigator(
          onGenerateRoute: (settings) {
            page = Post(); //postTab의 Post()위젯
            return MaterialPageRoute(builder: (_) => page);


          },
        ),

        drawer: Drawer(
          // 리스트뷰 추가
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // 드로워해더 추가
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              // 리스트타일 추가
              ListTile(
                title: Text('게시판'),
                onTap: (){
                  // 네이게이터 팝을 통해 드로워를 닫는다.
                  setState(() {
                    page = Post();
                    Navigator.pop(context);
                  });
                },
              ),
              // 리스트타일 추가
              ListTile(
                title: Text('종목저장소'),
                onTap: (){
                  // 드로워를 닫음
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Text('프로필'),
                    Icon(Icons.home),
                  ],
                ),

                onTap: (){
                  // 드로워를 닫음
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),


    );
  }
}
