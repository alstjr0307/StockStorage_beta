import 'package:flutter/material.dart';

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
    return Container(
      child: Center(
        child: Text(selectedResult),
      )
    );
    // TODO: implement buildResults
    throw UnimplementedError();
  }
  final List<String> listExample;
  Search(this.listExample);
  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    throw UnimplementedError();
  }
}