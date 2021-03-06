import 'package:flutter/material.dart';

import 'dart:async';


import 'package:dio/dio.dart';
import 'package:flutter_app/all/allDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'addPost.dart';
import 'freesearchpage.dart';
class FreePost extends StatefulWidget {
  @override
  _FreePostState createState() => _FreePostState();
}

class _FreePostState extends State<FreePost>
    with AutomaticKeepAliveClientMixin<FreePost> {

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-6925657557995580/2904161407', //자신의 UnitID
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(),
  );
  AdWidget adWidget;
  Container adContainer;



  ScrollController _sc = new ScrollController();

  static int page = 0;
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  int maxpage;
  var posttype = '';
  var sharedPreferences;
  var token;
  @override
  void initState() {
    _getMoreData(page);
    Future(() async => await myBanner.load()).then((_) {
      if (!mounted) return;
      setState(() {
        adWidget = AdWidget(
          ad: myBanner,
        );
        adContainer = Container(
          alignment: Alignment.center,
          child: adWidget,
          width: myBanner.size.width.toDouble(),
          height: myBanner.size.height.toDouble(),
        );
      });
    });
    super.initState();


    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        _getMoreData(page);
      }
    });
    print('이닛');
  }

  @override
  void dispose() {

    _sc.dispose();
    page = 0;
    posts = [];
    isLoading = false;
    myBanner.dispose();
    super.dispose();
  }

  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];

    sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString("token"); //token 값 불러오기

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = "http://13.125.62.90/api/v1/BlogPostsList/?category=F&page=" +
          (index + 1).toString();
      print('url'+url);
      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;
      print('맥페${maxpage}');
      print(response.data['results']);
      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        tList[i]['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(tList[i]['create_dt']));
      }

      print('중간중간');
      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
    }
  }

  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      _getMoreData(page);
    });
  }

  Widget _buildList() {
    return Expanded(
      child: Container(
        child: RefreshIndicator(
          child: ListView.builder(
              itemCount: posts.length +1,
              controller: _sc,
              // Add one more item for progress indicator
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (BuildContext context, int index) {
                print('index${index}');
                if (index == posts.length) {
                  return _buildProgressIndicator();


                }
                else {
                  return Container(
                    margin: new EdgeInsets.fromLTRB(5, 0, 5, 0),
                    width: 25.0,
                    height: 80.0,
                    child: InkWell(
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                        color: Colors.white70,
                        elevation: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10.0,0,8.0,0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(),
                                    Text(
                                      (posts[index]['title']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.person, size:15),
                                              Text(
                                                (posts[index]['writer'].toString()), style: TextStyle(fontSize: 12),
                                              ),
                                              SizedBox(width:10),
                                              Icon(Icons.comment, size: 15, color: Colors.redAccent,),
                                              Text(
                                                  ' ${posts[index]['comment'].toString()}', style: TextStyle(fontSize:12,color: Colors.red)),

                                              SizedBox(width:10),
                                              Icon(Icons.thumb_up, size:15, color: Colors.red,),
                                              Text(' ${posts[index]['likes'].toString()}', style: TextStyle(fontSize :12, color: Colors.red))

                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.timer, size: 12,color: Colors.grey),
                                            Text(posts[index]['time'],style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => allDetail(
                              index: posts[index]["id"],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }),
          onRefresh: _getData,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
  Map user;
  List data;
  Widget screen;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('자유게시판'),
        actions: [
          if (token !=null)
            IconButton(icon: Icon(Icons.add), onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPost()
                  )
              );

            }),
          IconButton(icon: Icon(Icons.search), onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>FreeSearchPage()
                )
            );
          })
        ],
      ),

      body: Column(
        children: [
          adContainer ?? Container(),
          _buildList(),
        ],
      ),
    );
  }

}

