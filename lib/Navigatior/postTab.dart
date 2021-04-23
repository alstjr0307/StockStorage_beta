import 'package:flutter/material.dart';
import 'package:flutter_app/all/allpost.dart';
import 'package:flutter_app/domestic/domesticPost.dart';
import 'package:flutter_app/foreign/ForeignPost.dart';
import 'package:flutter_app/free/freePost.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  TabController tabController; //하단 탭바 컨트롤러

  Widget all = AllPost();

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  List _widgetOptions = [
    AllPost(),
    ForeignPost(),
    DomesticPost(),
    FreePost(),
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //뒤로가기 막기
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: SalomonBottomBar(


          currentIndex: _selectedIndex,
          //현재 선택된 Index
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              title: Text('최신'),
              icon: Icon(Icons.list),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              title: Text('해외주식'),
              icon: Icon(Icons.attach_money),
              selectedColor: Colors.pink,
            ),
            SalomonBottomBarItem(
              title: Text('국내주식'),
              icon: Icon(Icons.assessment ),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              title: Text('자유게시판'),
              icon: Icon(Icons.library_books),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
