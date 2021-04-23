import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Navigatior/Storage/storagepost.dart';

import 'dart:convert';
import 'package:json_table/json_table.dart';
import 'package:flutter/services.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
class Storage extends StatefulWidget {
  @override
  _StorageState createState() => _StorageState();
}

class _StorageState extends State<Storage> with TickerProviderStateMixin {
  TextEditingController controller = new TextEditingController();


  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }
  var json;

  @override
  Widget build(BuildContext context) {
    return LoadData();
  }
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);

    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _loadFromAsset();
    BackButtonInterceptor.add(myInterceptor);
  }

  Future<String> _loadFromAsset() async {
    final String data = await rootBundle.loadString("assets/KStock.json");
    json = jsonDecode(data);
    setState(() {
      for (Map stock in json) {
        _stocks.add(Stocks.fromJson(stock));
      }
    });
    return data;
  }

  /*
  Widget LoadJson(BuildContext context) {
    return FutureBuilder(
        future: _loadFromAsset(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.amber),
                  )),
            );
          else {
            return Scaffold(
                body: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: JsonTable(
                            json,
                            showColumnToggle: true,
                            tableHeaderBuilder: (String header) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    color: Colors.grey[300]),
                                child: Text(
                                  header,
                                  textAlign: TextAlign.center,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .display1
                                      .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      color: Colors.black87),
                                ),
                              );
                            },
                            tableCellBuilder: (value) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5,
                                        color: Colors.grey.withOpacity(0.5))),
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .display1
                                      .copyWith(
                                      fontSize: 14.0, color: Colors.grey[900]),
                                ),
                              );
                            },
                            allowRowHighlight: true,
                            rowHighlightColor: Colors.yellow[500].withOpacity(
                                0.7),
                            paginationRowCount: 20,
                          ),
                        ),




                      ],
                    )


                )

            );
          }
        }
    );
  } */
  @override
  Widget LoadData() {
    return WillPopScope(
      child: new Scaffold(
        body: new Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).primaryColor,
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: '종목 검색', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: _searchResult.length != 0 || controller.text.isNotEmpty
                  ? new ListView.builder(
                      itemCount: _searchResult.length,
                      itemBuilder: (context, i) {
                        return new Card(
                          child: InkWell(
                            child: new ListTile(
                              title: new Text(_searchResult[i].name),

                                subtitle: Text(_searchResult[i].descrip),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StoragePost(tag: _searchResult[i].name)));
                            },
                          ),
                          margin: const EdgeInsets.all(0.0),

                        );
                      },
                    )
                  : new ListView.builder(
                      itemCount: _stocks.length,
                      itemBuilder: (context, index) {
                        return new Card(
                          child: InkWell(
                            child: new ListTile(
                              title: new Text(_stocks[index].name),
                              subtitle: new Text(_stocks[index].descrip),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StoragePost(tag: _stocks[index].name)));
                            },
                          ),
                          margin: const EdgeInsets.all(0.0),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _stocks.forEach((_stocks) {
      if (_stocks.name.contains(text) || _stocks.descrip.contains(text))
        _searchResult.add(_stocks);
    });

    setState(() {});
  }
}

List<Stocks> _searchResult = [];

List<Stocks> _stocks = [];

class Stocks {
  final String name, descrip;

  Stocks({this.name, this.descrip});

  factory Stocks.fromJson(Map<String, dynamic> json) {
    return new Stocks(
      name: json['name'],
      descrip: json['market'],
    );
  }
}
