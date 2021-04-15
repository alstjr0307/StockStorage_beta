import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../foreign/ForeignDetail.dart';
import 'domesticDetail.dart';
import 'package:dio/dio.dart';
class DomesticPost extends StatefulWidget {
  @override
  _DomesticPostState createState() => _DomesticPostState();
}

class _DomesticPostState extends State<DomesticPost>
    with AutomaticKeepAliveClientMixin<DomesticPost> {

  ScrollController _sc = new ScrollController();
  static int page = 0;
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();

  @override
  void initState() {
    this._getMoreData(page);
    super.initState();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        this._getMoreData(page);
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

    super.dispose();
  }
  void _getMoreData(int index) async {
    List tList = [];
    print('1');
    if (!isLoading) {
      print(isLoading);
      setState(() {
        isLoading = true;
      });

      print(isLoading);
      var url = "http://13.125.62.90/api/v1/BlogPosts/?category=d&page=" +
          (index+1).toString();
      print(url);
      final response = await dio.get(url);
      print('1');
      tList = [];
      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
      }
      print(tList[0]['title']);
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


  Widget _buildList() {
    print('13');

    return ListView.builder(
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
              onTap: (){Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DomesticDetail(index: posts[index]["id"])));},

              title: Text((posts[index]['title'])),
              subtitle: Text((posts[index]['owner'].toString())),


            );

            return Container();
          }
        });
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
      body:
      _buildList(),

    );
  }
}
