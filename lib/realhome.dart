import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class RealHome extends StatelessWidget {
  var allList = [];
  var forList = [];
  var domList = [];
  var freeList = [];

  final dio = new Dio();

  Future<List> getPostAll() async {
    Map<String, List> posts;
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    print(token);
    var urlall = "http://13.125.62.90/api/v1/BlogPosts/";
    var urlFor = "http://13.125.62.90/api/v1/BlogPosts/?category=F";
    var urldom = "http://13.125.62.90/api/v1/BlogPosts/?category=D";
    var urlfree = "http://13.125.62.90/api/v1/BlogPosts/?category=R";

    final responseall = await dio.get(urlall,
        options: Options(headers: {"Authorization": "Token ${token}"}));
    print('1');
    final responsefor = await dio.get(urlFor,
        options: Options(headers: {"Authorization": "Token ${token}"}));
    final responsedom = await dio.get(urldom,
        options: Options(headers: {"Authorization": "Token ${token}"}));
    final responsefree = await dio.get(urlfree,
        options: Options(headers: {"Authorization": "Token ${token}"}));
    allList = responseall.data['results'];

    forList = responsefor.data['results'];
    domList = responsedom.data['results'];
    freeList = responsefree.data['results'];

    return freeList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getPostAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: ListView(
                children: [
                  PostAll(allList, context),
                  PostFor(forList, context),
                  PostDom(domList, context),
                  PostFree(freeList, context),
                ],
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

Widget PostAll(List posts, BuildContext context) {
  return Container(
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('최신글', style: TextStyle(fontWeight: FontWeight.bold),),
                IconButton(icon: Icon(Icons.more_horiz), onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>AllPost(
                      )
                    )
                  );
                })
              ],
            ),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title:
                      Text(posts[0]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[0]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => allDetail(
                                  index: posts[0]['id'],
                                )));
                  },
                ),
                ListTile(
                  title:
                      Text(posts[1]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[1]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                ListTile(
                  title:
                      Text(posts[2]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[2]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                )
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('해외주식'),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title:
                      Text(posts[0]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[0]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => allDetail(
                                  index: posts[0]['id'],
                                )));
                  },
                ),
                ListTile(
                  title:
                      Text(posts[1]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[1]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                ListTile(
                  title:
                      Text(posts[2]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[2]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                )
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('국내주식'),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title:
                      Text(posts[0]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[0]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => allDetail(
                                  index: posts[0]['id'],
                                )));
                  },
                ),
                ListTile(
                  title:
                      Text(posts[1]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[1]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                ListTile(
                  title:
                      Text(posts[2]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[2]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                )
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('자유게시판'),
            padding: EdgeInsets.only(left: 10),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title:
                      Text(posts[0]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[0]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => allDetail(
                                  index: posts[0]['id'],
                                )));
                  },
                ),
                ListTile(
                  title:
                      Text(posts[1]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[1]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                ListTile(
                  title:
                      Text(posts[2]['title'], style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    posts[2]['writer'],
                    style: TextStyle(fontSize: 10),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
