import 'package:flutter/material.dart';
import 'package:flutter_app/all/allDetail.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchController = TextEditingController();
  var searchOption = '제목+내용';
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-6925657557995580/6651834727', //자신의 UnitID
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(),
  );
  AdWidget adWidget;
  Container adContainer;

  static int page = 0;
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  int maxpage;
  var posttype = '';
  var sharedPreferences;
  var token;

  ScrollController _sc = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('전체 검색')),
        body: Column(
          children: [
            _SearchSection(),
            _buildList(),
          ],
        ));
  }

  Widget _SearchSection() {
    return Row(
      children: [
        new Flexible(
          child: TextField(
            autofocus: true,
            controller: searchController,
            style: new TextStyle(
              color: Colors.black,
            ),
            decoration: new InputDecoration(
                fillColor: Colors.white,
                prefixIcon: new Icon(Icons.search, color: Colors.blue),
                hintText: '검색어를 입력해주세요',
                hintStyle: new TextStyle(color: Colors.blue)),
          ),
        ),
        Container(

          child: DropdownButton(
            hint: Text(
              searchOption,
              style: TextStyle(color: Colors.blue),
            ),
            iconSize: 30.0,
            style: TextStyle(color: Colors.blue),
            items: ['제목', '내용', '제목+내용'].map(
              (val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              },
            ).toList(),
            onChanged: (val) {
              setState(
                () {
                  searchOption = val;
                },
              );
            },
          ),
        ),
        IconButton(icon: Icon(Icons.search), onPressed: () {
          page = 0;
          posts = [];
          isLoading = false;
          if (searchOption == '제목+내용')
            _getMoreData(page);
          else if(searchOption == '제목')
            _getMoreDataTitle(page);
          else if(searchOption =='내용')
            _getMoreDataContent(page);

          _sc.addListener(() {
            if (_sc.position.pixels == _sc.position.maxScrollExtent &&
                page < maxpage) {
              _getMoreData(page);
            }
          });
        })
      ],
    );
  }
  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      _getMoreData(page);
    });
  }
  void _getMoreDataContent(int index) async {
    //데이터 추가하기
    List tList = [];

    sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString("token"); //token 값 불러오기

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = "http://13.125.62.90/api/v1/BlogPosts/?contentsearch=${searchController.text}&page=" +
          (index + 1).toString();
      print(url);
      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;
      print('맥페${maxpage}');
      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        if (response.data['results'][i]['category'] == 'D')
          tList[i]['type'] = '국내';
        else if (response.data['results'][i]['category'] == 'F')
          tList[i]['type'] = '해외';
        else if (response.data['results'][i]['category'] == 'R')
          tList[i]['type'] = '자유';
        tList[i]['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(tList[i]['create_dt']));
      }


      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
    }
  }
  void _getMoreDataTitle(int index) async {
    //데이터 추가하기
    List tList = [];

    sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString("token"); //token 값 불러오기

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = "http://13.125.62.90/api/v1/BlogPosts/?titlesearch=${searchController.text}&page=" +
          (index + 1).toString();
      print(url);
      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;
      print('맥페${maxpage}');
      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        if (response.data['results'][i]['category'] == 'D')
          tList[i]['type'] = '국내';
        else if (response.data['results'][i]['category'] == 'F')
          tList[i]['type'] = '해외';
        else if (response.data['results'][i]['category'] == 'R')
          tList[i]['type'] = '자유';
        tList[i]['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(tList[i]['create_dt']));
      }


      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
    }
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

      var url = "http://13.125.62.90/api/v1/BlogPosts/?multisearch=${searchController.text}&page=" +
          (index + 1).toString();
      print(url);
      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;
      print('맥페${maxpage}');
      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        if (response.data['results'][i]['category'] == 'D')
          tList[i]['type'] = '국내';
        else if (response.data['results'][i]['category'] == 'F')
          tList[i]['type'] = '해외';
        else if (response.data['results'][i]['category'] == 'R')
          tList[i]['type'] = '자유';
        tList[i]['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(tList[i]['create_dt']));
      }


      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
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
                            Container(
                              margin: const EdgeInsets.all(4.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent,
                                border: Border.all(width: 1.0, color: Colors.white),
                              ),
                              child: Text(posts[index]['type'],
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            )
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
}
