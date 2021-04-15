import 'package:flutter/material.dart';

class Blog {
  final int id;
  final String title;
  final String content;
  final String category;
  final String create_dt;
  final int owner;

  Blog(
      {@required this.id,
        @required this.title,
        @required this.content,
        @required this.category,
        @required this.create_dt,
        @required this.owner});

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      create_dt: json['create_dt'],
      owner: json['owner'],
    );
  }
}

class User {
  final int id;
  final String first_name;

  User({@required this.id, @required this.first_name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      first_name: json['first_name'],
    );
  }
}
