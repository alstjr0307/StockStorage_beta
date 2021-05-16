

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/search/allsearch.dart';
import 'domestic/domesticDetail.dart';
import 'foreign/ForeignDetail.dart';
import 'foreign/ForeignPost.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


import 'dart:async';
import 'all/allDetail.dart';

import 'all/allpost.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'free/freeDetail.dart';
import 'profile/profile.dart';

import 'profile/loginpage.dart';
import 'domestic/domesticPost.dart';

import 'free/freePost.dart';
import 'Navigatior/Storage/storage.dart';

class RealHome extends StatefulWidget {
  final List<String> list = List.generate(10, (index) => "Text $index");

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
  var output;
  var username;
  var sharedPreferences;
  var allList = [];
  var forList = [];
  var domList = [];
  var freeList = [];
  final dio = new Dio();
  var popularTag = [];

  var result;
  ScrollController _scrollController = new ScrollController();

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      username = sharedPreferences.getString("nickname");
    }
    print('토큰' + sharedPreferences.getString("token"));
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  void dispose() {
    super.dispose();
    searchcontroller.dispose();
    _scrollController.dispose();
  }

  Future<List> getPostAll() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    print(token);
    var urlall = "http://13.125.62.90/api/v1/BlogPosts/";
    var urlFor = "http://13.125.62.90/api/v1/BlogPosts/?category=F";
    var urldom = "http://13.125.62.90/api/v1/BlogPosts/?category=D";
    var urlfree = "http://13.125.62.90/api/v1/BlogPosts/?category=R";
    var tag = "http://13.125.62.90/api/v1/TaggitTaggedItem/";
    print('중간');
    final responsetag = await dio.get(tag,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          },
        ));
    final responseall = await dio.get(urlall,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          },
        ));
    print(responseall.statusCode);
    final responsefor = await dio.get(urlFor,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          },
        ));
    final responsedom = await dio.get(urldom,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          },
        ));
    final responsefree = await dio.get(urlfree,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          },
        ));
    for (var i = 0; i < 10; i++) {
      popularTag.add(responsetag.data[i]['name']);
    }
    final map = <String, int>{};
    for (final letter in popularTag) {
      map[letter] = map.containsKey(letter) ? map[letter] + 1 : 1;
    }

// Sort the list of the map keys by the map values.
    output = map.keys.toList(growable: false);
    output.sort((k1, k2) => map[k2].compareTo(map[k1]));
    print(output);
    Timer.periodic(Duration(seconds: 3), (timer) {

      _scrollController.animateTo(
        (timer.tick % 6) *
            _scrollController.position.maxScrollExtent /
            (output.length - 1),
        curve: Curves.easeInCubic,
        duration: const Duration(milliseconds: 300),
      );
    });
    allList = responseall.data['results'];
    print('중간');
    forList = responsefor.data['results'];
    domList = responsedom.data['results'];
    freeList = responsefree.data['results'];
    print(responseall.statusCode);
    if (responseall.statusCode == 200)
      return freeList;
    else {
      return Future.error(responseall.statusCode);
    }
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
                  if (username == null)
                    Text(
                      '비회원',
                      style: TextStyle(
                          fontFamily: 'Hoon', fontWeight: FontWeight.bold),
                    )
                  else
                    Text(
                      username,
                      style: TextStyle(
                          fontFamily: 'Hoon',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  if (username == null)
                    TextButton(
                      child: Text('로그인'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginPage()));
                      },
                    ),
                  if (username != null)
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          alignment: Alignment.centerLeft),
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
                        username = null;

                        new Future.delayed(new Duration(seconds: 1), () {
                          //pop dialog
                          setState(() {});
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        margin: EdgeInsets.all(0),
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
                  //프로필 가기
                  if (username != null)
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          alignment: Alignment.centerLeft),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Profile()));
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
                            "내 프로필",
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
              hoverColor: Colors.red,
              title: Text(drawerlist[i], style: TextStyle(fontFamily: 'gyeongi'),),
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

  //검색기능
  final searchcontroller = TextEditingController();
  Widget appBarTitle = new Row(children: [
    Text("주식저장소 홈", style: TextStyle(fontFamily: 'gyeongi')),
    Icon(Icons.bar_chart),
  ]);
  Icon actionIcon = new Icon(Icons.search);
  String hintText = "게시물 검색";

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: appBarTitle,
      actions: [
        new IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(Icons.close);
                this.appBarTitle = Row(
                  children: [
                    Flexible(
                      child: new TextField(
                        autofocus: true,
                        controller: searchcontroller,
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                        decoration: new InputDecoration(
                            prefixIcon:
                                new Icon(Icons.search, color: Colors.white),
                            hintText: hintText,
                            hintStyle: new TextStyle(color: Colors.white)),
                      ),
                    ),
                    new IconButton(
                        icon: Icon(Icons.arrow_right_alt),
                        onPressed: () {
                          setState(() {
                            this.actionIcon = new Icon(Icons.search);
                            this.appBarTitle = new Text("주식 저장소 홈",
                                style: TextStyle(fontFamily: 'gyeongi'));
                          });

                          if (searchcontroller.text != '') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllSearch(
                                        search: searchcontroller.text)));
                          }
                        })
                  ],
                );
              } else {
                print(searchcontroller.text);
                this.actionIcon = new Icon(Icons.search);
                this.appBarTitle = new Text("주식 저장소 홈",
                    style: TextStyle(fontFamily: 'gyeongi'));
              }
            });
          },
        ),
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
              appBar: buildAppBar(context),
              drawer: CustomDrawer(),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Stock(result, output, context, _scrollController),
                    PostAll(allList, context),
                    PostFor(forList, context),
                    PostDom(domList, context),
                    PostFree(freeList, context),
                    Image(image: AssetImage('assets/photos/example.PNG'))
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('데이터를 불러올 수 없습니다.\n인터넷 연결 상태를 확인해주세요'),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => RealHome()),
                          );
                        },
                        child: Text('재시도')),
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

Widget Stock(String taglist, List output, BuildContext context,
    ScrollController _scrollController) {
  return Container(
      child: Card(
          color: Colors.white60,
          elevation: 1,
          shadowColor: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Text(' 실시간 인기 종목',
                        style: TextStyle(
                            fontFamily: 'Hoon',
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    SizedBox(width: 30),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: PageScrollPhysics(),
                          // this is what you are looking for
                          scrollDirection: Axis.vertical,
                          itemCount: output.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.white54,
                                height: 50,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(

                                      child: Text(output[index],
                                          style: TextStyle(
                                            fontFamily: 'gyeongi',
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w800))
                                    ),
                                  ],
                                ));
                          },
                        ),
                      ),
                    ),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'gyeongi'),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'gyeongi'),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForeignPost()));
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
                              builder: (context) => ForeignDetail(
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'gyeongi'),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DomesticPost()));
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
                              builder: (context) => DomesticDetail(
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'gyeongi'),
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
                          MaterialPageRoute(builder: (context) => FreePost()));
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
                              builder: (context) => FreeDetail(
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
