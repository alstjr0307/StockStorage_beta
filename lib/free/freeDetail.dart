import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';


class FreeDetail extends StatefulWidget {
  final int index;

  const FreeDetail({Key key, this.index}) : super(key: key);

  @override
  _FreeDetailState createState() => _FreeDetailState();
}

class _FreeDetailState extends State<FreeDetail> {
  Map content;
  Map commentmap;
  Map postlistmap;
  var comment;
  var postlist;
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent,  RouteInfo info) {
    Navigator.pop(context); // Do some stuff.
    return true;
  }
  Future getData() async {
    final response = await http
        .get(Uri.http('13.125.62.90', "api/v1/BlogPosts/${widget.index}/"));
    content = jsonDecode(utf8.decode(response.bodyBytes));
    print('${content['id']}');
    var comresponse = await http.get(Uri.http('13.125.62.90',
        'api/v1/BlogPostcomment', {'blogpost_connected': "${content['id']}"}));
    print('1');
    commentmap = jsonDecode(utf8.decode(comresponse.bodyBytes));
    comment = commentmap['results'];
    for (var i = 0; i < comment.length; i++) {
      var comuser = await http.get(Uri.http('13.125.62.90',
          'api/v1/AuthUser/${comment[i]['writer'].toString()}'));
      comment[i]["user"] =
      jsonDecode(utf8.decode(comuser.bodyBytes))["first_name"];
    }
    final listresponse = await http
        .get(Uri.http('13.125.62.90', "api/v1/BlogPosts", {'category': 'f'}));

    postlistmap = jsonDecode(utf8.decode(listresponse.bodyBytes));
    postlist= postlistmap['results'];
    print(postlist[0]['title']);
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.amber),
                ));
          else
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Html(
                      data: content['content'],
                      onLinkTap: (url) {
                        print("Opening $url...");
                      },
                    ),
                    scrollDirection: Axis.vertical,
                  ),
                ),
                Column(
                  children: [
                    for (var i in comment)
                      Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    child: Text(
                                      i['user'],
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    )),
                                Text(
                                  i['content'],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: postlist.length,
                      itemBuilder: (context, position) {
                        return InkWell(
                          child: Card(
                            child: Row(children: <Widget>[
                              Text(postlist[position]['title']),
                              Text(postlist[position]['owner'].toString()),
                            ]),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FreeDetail(
                                        index: postlist[position]["id"])));
                          },
                        );
                      }),
                ),
              ],
            );
        },
      ),
    );
  }
}
