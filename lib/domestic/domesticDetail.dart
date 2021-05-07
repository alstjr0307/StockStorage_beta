import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'domesticPost.dart';
import '../model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

class DomesticDetail extends StatefulWidget {
  final int index;

  const DomesticDetail({Key key, this.index}) : super(key: key);

  @override
  _DomesticDetailState createState() => _DomesticDetailState();
}

class _DomesticDetailState extends State<DomesticDetail> {
  Map content;
  var comment;
  var postlist;

  Future getData() async {
    final response = await http
        .get(Uri.http('13.125.62.90', "api/v1/BlogPosts/${widget.index}/"));
    content = jsonDecode(utf8.decode(response.bodyBytes));
    print('${content['id']}');
    var comresponse = await http.get(Uri.http('13.125.62.90',
        'api/v1/BlogPostcomment', {'blogpost_connected': "${content['id']}"}));
    print('1');
    comment = jsonDecode(utf8.decode(comresponse.bodyBytes));
    for (var i = 0; i < comment.length; i++) {
      var comuser = await http.get(Uri.http('13.125.62.90',
          'api/v1/AuthUser/${comment[i]['writer'].toString()}'));
      comment[i]["user"] =
      jsonDecode(utf8.decode(comuser.bodyBytes))["first_name"];
    }
    final listresponse = await http
        .get(Uri.http('13.125.62.90', "api/v1/BlogPosts", {'category': 'd'}));

    postlist = jsonDecode(utf8.decode(listresponse.bodyBytes));
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DomesticDetail(
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
