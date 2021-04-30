import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'storagedetail.dart';
import 'package:flutter_app/Navigatior/postTab.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/all/allDetail.dart';

class StoragePost extends StatefulWidget {
  final String tag;

  const StoragePost({Key key, this.tag}) : super(key: key);

  @override
  _StoragePostState createState() => _StoragePostState();
}

class _StoragePostState extends State<StoragePost>
    with TickerProviderStateMixin {
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context); // Do some stuff.
    return true;
  }

  bool boolcontent = true;
  ScrollController _sc = new ScrollController();
  static int page = 0;
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  int maxpage;

  @override
  @override
  void initState() {
    this._getMoreData(page);
    super.initState();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        this._getMoreData(page);
      }
    });
    BackButtonInterceptor.add(myInterceptor);
    print('이닛');
  }

  @override
  void dispose() {
    _sc.dispose();
    page = 0;
    posts = [];
    isLoading = false;
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];

    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token"); //token 값 불러오기
    print('testmei');
    List postlist = [];
    if (!isLoading) {
      print(isLoading);
      setState(() {
        isLoading = true;
      });
      var tagitemurl =
          "http://13.125.62.90/api/v1/TaggitTaggedItem/?namee=${widget.tag}";
      print(tagitemurl);
      final taggitemresponse = await dio.get(tagitemurl,
          options: Options(headers: {"Authorization": "Token ${token}"}));
      print(taggitemresponse.data);
      print(taggitemresponse.data.length);
      for (var i = 0; i < taggitemresponse.data.length; i++) {
        postlist.add(taggitemresponse.data[i]['object_id'].toString());
      }

      String idlist = '';
      for (var i = 0; i < postlist.length; i++) {
        idlist = idlist + postlist[i] + ',';
      }
      var url = "http://13.125.62.90/api/v1/BlogPosts/?id_in=${idlist}&page=" +
          (index + 1).toString();

      final response = await dio.get(url,
          options: Options(headers: {"Authorization": "Token ${token}"}));
      maxpage = response.data['count'] ~/ 10 + 1;

      tList = [];
      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
      }
      boolcontent = true;

      print(page);
      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
      print(posts.length);
      print(page);
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
    print('13');
    if (boolcontent == true)
      return RefreshIndicator(
        child: ListView.builder(
            itemCount: posts.length + 1,
            controller: _sc,
            // Add one more item for progress indicator
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (BuildContext context, int index) {
              print('ㄱㄱ ${posts.length}');
              print('index${index}');
              if (index == posts.length) {
                return _buildProgressIndicator();
              } else {
                return new ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                storageDetail(index: posts[index]["id"])));
                  },
                  title: Text((posts[index]['title'])),
                  subtitle: Text((posts[index]['writer'].toString())),
                );

                return Container();
              }
            }),
        onRefresh: _getData,
      );
    else {
      return Container(
        child: Center(
            child: Text(
          '게시물이 없습니다',
          style: TextStyle(color: Colors.blueGrey, fontSize: 20),
        )),
      );
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_left),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: _buildList(),
    );
  }
}
