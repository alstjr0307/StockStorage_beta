import 'package:flutter/material.dart';
import 'package:flutter_app/all/allpost.dart';
import 'package:flutter_app/domestic/domesticPost.dart';
import 'package:flutter_app/foreign/ForeignPost.dart';
import 'package:flutter_app/free/freePost.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';

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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(.60),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          currentIndex: _selectedIndex,
          //현재 선택된 Index
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              title: Text('최신'),
              icon: Icon(Icons.list),
            ),
            BottomNavigationBarItem(
              title: Text('해외주식'),
              icon: Icon(Icons.attach_money),
            ),
            BottomNavigationBarItem(
              title: Text('국내주식'),
              icon: Icon(Icons.assessment ),
            ),
            BottomNavigationBarItem(
              title: Text('자유게시판'),
              icon: Icon(Icons.library_books),
            ),
          ],
        ),
      ),
    );
  }
}
