import 'package:flutter/material.dart';
import 'package:flutter_app/search/titlesearch.dart';

class Search extends SearchDelegate{

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget> [
      IconButton(
        icon:Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
    throw UnimplementedError();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // TODO: implement buildLeading
    throw UnimplementedError();
  }
  String selectedResult;
  @override
  Widget buildResults(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TitleSearch(title: selectedResult)));
    // TODO: implement buildResults
    throw UnimplementedError();
  }
  final List<String> listExample;
  Search(this.listExample);
  List<String> recentList = ["Text 4", "Text 3"];

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestionList = [];
    query.isEmpty
    ? suggestionList = recentList
    : suggestionList.addAll(listExample.where(
        (element) => element.contains(query),

    ));
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            suggestionList[index],
          ),
          onTap: () {
            selectedResult = suggestionList[index];
            showResults(context);
          }
        );
      },
    );

    throw UnimplementedError();
  }
}