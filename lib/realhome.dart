import 'package:flutter/material.dart';
import 'package:flutter_app/search/titlesearch.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:yahoofin/yahoofin.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'dart:convert';
import 'dart:async';
import 'all/allDetail.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'all/allpost.dart';
import 'package:flutter_app/Navigatior/postTab.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'profile/profile.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'profile/loginpage.dart';
import 'domestic/domesticPost.dart';
import 'foreign/ForeignPost.dart';
import 'free/freePost.dart';
import 'Navigatior/Storage/storage.dart';
import 'package:flutter_app/Widget/Search.dart';




class RealHome extends StatefulWidget {
  final List list = List.generate(10, (index) =>"Text $index");
  @override
  _RealHomeState createState() => _RealHomeState();
}

class _RealHomeState extends State<RealHome> {
  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  List drawerlist = ['최신글', '국내주식게시판', '해외주식게시판', '자유게시판', '종목저장소'];
  List pagelist = [
    AllPost(),
    DomesticPost(),
    ForeignPost(),
    FreePost(),
    Storage()
  ];
  String username;
  var sharedPreferences;
  var allList = [];
  var forList = [];
  var domList = [];
  var freeList = [];
  final dio = new Dio();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List> getPostAll() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    print(token);
    var urlall = "http://13.125.62.90/api/v1/BlogPosts/";
    var urlFor = "http://13.125.62.90/api/v1/BlogPosts/?category=F";
    var urldom = "http://13.125.62.90/api/v1/BlogPosts/?category=D";
    var urlfree = "http://13.125.62.90/api/v1/BlogPosts/?category=R";

    print('중간');
    final responseall = await dio.get(urlall);
    print('1');
    print(responseall.statusCode);
    final responsefor = await dio.get(
      urlFor,
    );
    final responsedom = await dio.get(
      urldom,
    );
    final responsefree = await dio.get(
      urlfree,
    );

    allList = responseall.data['results'];
    print('중간');
    forList = responsefor.data['results'];
    domList = responsedom.data['results'];
    freeList = responsefree.data['results'];
    print(username);
    username = sharedPreferences.getString('nickname');
    return freeList;
  }

  Widget CustomDrawer() {
    return Drawer(
      // 리스트뷰 추가
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // 드로워해더 추가
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (username == null) Text('비회원') else Text(username),
                  SizedBox(
                    height: 50,
                  ),
                  if (username == null)
                    TextButton(
                      child: Text('로그인'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginPage()));
                      },
                    )
                  else
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: new Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  new CircularProgressIndicator(),
                                  new Text("로그아웃중"),
                                ],
                              ),
                            );
                          },
                        );
                        sharedPreferences.clear();
                        sharedPreferences.commit();
                        setState(() {});
                        new Future.delayed(new Duration(seconds: 1), () {
                          //pop dialog

                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(width: 1.0, color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            "로그아웃",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            decoration: BoxDecoration(color: Colors.black26),
          ),
          // 리스트타일 추가
          for (var i = 0; i < drawerlist.length; i++)
            ListTile(
              title: Text(drawerlist[i]),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => pagelist[i]));
                });
              },
            ),
        ],
      ),
    );
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      username = sharedPreferences.getString("nickname");
    }
    print(sharedPreferences.getString("token"));
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: Row(
        children: [
          Icon(
            Icons.bar_chart,
            size: 30,
          ),
          Text(
            '주식저장소 홈',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            showSearch(context: context, delegate: Search(widget.list));
          },
          icon: Icon(Icons.search),
        ),
        if (username != null)
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profile()));
            },
          )
      ],
    );
  }

  @override
  Widget build(BuildContext cont) {
    return FutureBuilder(
        future: getPostAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: buildAppBar(cont),
              drawer: CustomDrawer(),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Stock(),
                    PostAll(allList, context),
                    PostFor(forList, context),
                    PostDom(domList, context),
                    PostFree(freeList, context),
                    Image(image: AssetImage('assets/photos/example.PNG'))
                  ],
                ),
              ),
            );
          } else
            return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              )),
            );
        });
  }
}

Widget Stock() {
  return Container(
      child: Card(
          color: Colors.white60,
          elevation: 3,
          shadowColor: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Text('코스피'),
                  ],
                ),
              )
            ],
          )));
}

Widget PostAll(List posts, BuildContext context) {
  return Container(
    child: Card(
      color: Colors.white60,
      elevation: 3,
      shadowColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최신글',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                    child: Row(
                      children: [
                        Text(
                          '더보기',
                        ),
                        Icon(
                          Icons.arrow_right,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AllPost()));
                    })
              ],
            ),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < 6; i++)
                  ListTile(
                    title:
                        Text(posts[i]['title'], style: TextStyle(fontSize: 13)),
                    subtitle: Text(
                      posts[i]['writer'],
                      style: TextStyle(fontSize: 10),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => allDetail(
                                    index: posts[i]['id'],
                                  )));
                    },
                    dense: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget PostFor(List posts, BuildContext context) {
  return Container(
    child: Card(
      color: Colors.white60,
      elevation: 3,
      shadowColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '해외주식',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                    child: Row(
                      children: [
                        Text(
                          '더보기',
                        ),
                        Icon(
                          Icons.arrow_right,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AllPost()));
                    })
              ],
            ),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < 6; i++)
                  ListTile(
                    title:
                        Text(posts[i]['title'], style: TextStyle(fontSize: 13)),
                    subtitle: Text(
                      posts[i]['writer'],
                      style: TextStyle(fontSize: 10),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => allDetail(
                                    index: posts[i]['id'],
                                  )));
                    },
                    dense: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget PostDom(List posts, BuildContext context) {
  return Container(
    child: Card(
      color: Colors.white60,
      elevation: 3,
      shadowColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '국내주식',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                    child: Row(
                      children: [
                        Text(
                          '더보기',
                        ),
                        Icon(
                          Icons.arrow_right,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AllPost()));
                    })
              ],
            ),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < 6; i++)
                  ListTile(
                    title:
                        Text(posts[i]['title'], style: TextStyle(fontSize: 13)),
                    subtitle: Text(
                      posts[i]['writer'],
                      style: TextStyle(fontSize: 10),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => allDetail(
                                    index: posts[i]['id'],
                                  )));
                    },
                    dense: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget PostFree(List posts, BuildContext context) {
  return Container(
    child: Card(
      color: Colors.white60,
      elevation: 3,
      shadowColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '자유게시판',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                    child: Row(
                      children: [
                        Text(
                          '더보기',
                        ),
                        Icon(
                          Icons.arrow_right,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AllPost()));
                    })
              ],
            ),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < 6; i++)
                  ListTile(
                    title:
                        Text(posts[i]['title'], style: TextStyle(fontSize: 13)),
                    subtitle: Text(
                      posts[i]['writer'],
                      style: TextStyle(fontSize: 10),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => allDetail(
                                    index: posts[i]['id'],
                                  )));
                    },
                    dense: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
