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

  @override
  Widget build(BuildContext context) {
    final _libraryScreen = GlobalKey<NavigatorState>();
    final _playlistScreen = GlobalKey<NavigatorState>();
    final _searchScreen = GlobalKey<NavigatorState>();
    final _bibleScreen = GlobalKey<NavigatorState>();

    return WillPopScope( //뒤로가기 막기
      child: Scaffold(
        body: TabBarView(
          children: <Widget>[
            AllPost(),
            ForeignPost(),
            DomesticPost(),
            FreePost(),
          ],
          controller: tabController,
        ),
        appBar: AppBar(
          title: TabBar(
            tabs: <Tab>[
              Tab(
                child: Column(
                  children: [
                    Text(
                      '최신글',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  children: [
                    Text(
                      '해외주식',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  children: [
                    Text(
                      '국내주식',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  children: [
                    Text(
                      '자유게시판',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            controller: tabController,
          ),
        ),
      ),
    );
  }
}
