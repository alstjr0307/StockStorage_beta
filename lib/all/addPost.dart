import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'allDetail.dart';
import 'package:flutter_app/Navigatior/postTab.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool asTabs = false;
  String selectedValue;

  List<int> selectedItems = [];
  static const String appTitle = "Search Choices demo";
  final String loremIpsum = "Lorem sdf sdfipsum dsf sdf dolor";

  final List<DropdownMenuItem> items = [];

  String result = '';
  HtmlEditorController controller = HtmlEditorController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  String category;

  Future<List> _loadFromAsset() async {
    final String data = await rootBundle.loadString("assets/KStock.json");
    var json = jsonDecode(data);
    setState(() {
      for (Map stock in json) {
        items.add(DropdownMenuItem(
          child: Text(stock["name"]),
          value: stock["name"],
        ));
      }
    });
    return items;
  }

  @override
  void initState() {
    _loadFromAsset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 작성'),
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "제목을 입력해주세요",
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            child: Column(
              children: [
                HtmlEditor(
                  controller: controller,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: '내용을 입력해주세요',
                    shouldEnsureVisible: true,
                    //initialText: "<p>text content initial, if any</p>",
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    toolbarPosition: ToolbarPosition.aboveEditor,
                    //by default
                    toolbarType: ToolbarType.nativeScrollable,
                    //by default
                    onButtonPressed: (ButtonType type, bool status,
                        Function() updateStatus) {
                      print(
                          "button '${describeEnum(type)}' pressed, the current selected status is $status");
                      return true;
                    },
                    onDropdownChanged: (DropdownType type, dynamic changed,
                        Function(dynamic) updateSelectedItem) {
                      print(
                          "dropdown '${describeEnum(type)}' changed to $changed");
                      return true;
                    },
                    mediaLinkInsertInterceptor:
                        (String url, InsertFileType type) {
                      print(url);
                      return true;
                    },
                    mediaUploadInterceptor:
                        (PlatformFile file, InsertFileType type) async {
                      print(file.name); //filename
                      print(file.size); //size in bytes
                      print(file.extension); //file extension (eg jpeg or mp4)
                      return true;
                    },
                  ),
                  otherOptions: OtherOptions(height: 550),
                  callbacks: Callbacks(onBeforeCommand: (String currentHtml) {
                    print('html before change is $currentHtml');
                  }, onChange: (String changed) {
                    print('content changed to $changed');
                  }, onChangeCodeview: (String changed) {
                    print('code changed to $changed');
                  }, onDialogShown: () {
                    print('dialog shown');
                  }, onEnter: () {
                    print('enter/return pressed');
                  }, onFocus: () {
                    print('editor focused');
                  }, onBlur: () {
                    print('editor unfocused');
                  }, onBlurCodeview: () {
                    print('codeview either focused or unfocused');
                  }, onInit: () {
                    print('init');
                  },
                      //this is commented because it overrides the default Summernote handlers
                      /*onImageLinkInsert: (String? url) {
                    print(url ?? "unknown url");
                  },
                  onImageUpload: (FileUpload file) async {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                    print(file.base64);
                  },*/
                      onImageUploadError: (FileUpload file, String base64Str,
                          UploadError error) {
                    print(describeEnum(error));
                    print(base64Str ?? '');
                    if (file != null) {
                      print(file.name);
                      print(file.size);
                      print(file.type);
                    }
                  }, onKeyDown: (int keyCode) {
                    print('$keyCode key downed');
                  }, onKeyUp: (int keyCode) {
                    print('$keyCode key released');
                  }, onMouseDown: () {
                    print('mouse downed');
                  }, onMouseUp: () {
                    print('mouse released');
                  }, onPaste: () {
                    print('pasted into editor');
                  }, onScroll: () {
                    print('editor scrolled');
                  }),
                  plugins: [
                    SummernoteAtMention(
                        getSuggestionsMobile: (String value) {
                          var mentions = <String>['test1', 'test2', 'test3'];
                          return mentions
                              .where((element) => element.contains(value))
                              .toList();
                        },
                        mentionsWeb: ['test1', 'test2', 'test3'],
                        onSelect: (String value) {
                          print(value);
                        }),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
          Container(
            child: SearchableDropdown.multiple(
              items: items,
              selectedItems: selectedItems,
              hint: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("종목을 골라주세요"),
              ),
              searchHint: "종목 선택",
              onChanged: (value) {
                setState(() {
                  selectedItems = value;
                });
              },
              closeButton: (selectedItems) {
                return (selectedItems.isNotEmpty
                    ? "확인 ${selectedItems.length == 1 ? '"' + items[selectedItems.first].value.toString() + '"' : '(' + selectedItems.length.toString() + ')'}"
                    : "선택 안 하기");
              },
              isExpanded: true,
            ),
          ),
          Container(
            child: Row(
              children: [
                Text('게시판'),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Container(
                    child: DropdownButton(
                      hint: category == null
                          ? Text('게시판을 선택해주세요')
                          : Text(
                              category,
                              style: TextStyle(color: Colors.blue),
                            ),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['국내주식', '해외주식', '자유게시판'].map(
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
                            category = val;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  TextButton(
                    style:
                        TextButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () {
                      controller.clear();
                    },
                    child: Text('초기화', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  TextButton(
                    style:
                        TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                    onPressed: () async {
                      final txt = await controller.getText();

                      await addPost(titleController.text, txt, category);

                    },
                    child: Text('작성완료', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> addPost(String title, String content, String category) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("글 작성완료중"),
            ],
          ),
        );
      },
    );
    List tag;
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    var formatter = new DateFormat('yyyy-MM-dd H:m');
    print('하는중');
    var now = new DateTime.now();
    var str = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
    print(str);
    print(now);
    if (category == "국내주식") {
      category = "D";
    } else if (category == "해외주식")
      category = "F";
    else {
      category = "R";
    }
    final responseerw = await http.post(
        Uri.http('13.125.62.90', "api/v1/BlogPosts/"),
        headers: {
          "Authorization": "Token ${token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          <String, dynamic>{
            "title": title,
            "content": content,
            "slug": "none",
            "description": "none",
            "create_dt": str,
            "modify_dt": str,
            "category": category,
            "owner": sharedPreferences.getInt('userID')
          },
        ));
    print('responseerw'+responseerw.body);
    if (responseerw.statusCode == 201) {
      var postid = jsonDecode(responseerw.body)["id"];
      print(postid.toString());
      print(selectedItems[0]);
      for (var i = 0; i < selectedItems.length; i++) {
        print(items[selectedItems[i]].value.toString());
        final tagpost =
            await http.post(Uri.http('13.125.62.90', 'api/v1/TaggitTag/'),
                headers: {
                  "Authorization": "Token ${token}",
                  "Content-Type": "application/json",
                },
                body: jsonEncode(<String, dynamic>{
                  "slug": items[selectedItems[i]].value.toString() + 'z',
                  "name": items[selectedItems[i]].value.toString()
                }));
        if (tagpost.statusCode == 201) {
          var tagid = jsonDecode(tagpost.body)["id"];
          print('태그 새로추가 태그아이디는 ${tagid}');
          final taggit = await http.post(
            Uri.http('13.125.62.90', 'api/v1/TaggitTaggedItem/'),
            headers: {
              "Authorization": "Token ${token}",
              "Content-Type": "application/json"
            },
            body: jsonEncode(<String, dynamic>{
              "object": postid,
              "content_type": 14,
              "tag": tagid
            }),
          );
        } else if (tagpost.statusCode == 400) {
          print('ww${items[selectedItems[i]].value}');
          var tagg = await http.get(
            Uri.http('13.125.62.90', 'api/v1/TaggitTag/',
                {"name": items[selectedItems[i]].value}),
            headers: {
              "Authorization": "Token ${token}",
              "Content-Type": "application/json"
            },
          );
          print(tagg.statusCode);
          print(tagg.body);
          var tagid = jsonDecode(tagg.body)[0]['id'];
          final taggit = await http.post(
            Uri.http('13.125.62.90', 'api/v1/TaggitTaggedItem/'),
            headers: {
              "Authorization": "Token ${token}",
              "Content-Type": "application/json"
            },
            body: jsonEncode(<String, dynamic>{
              "object": postid,
              "content_type": 14,
              "tag": tagid
            }),
          );
          print('태깃 ${taggit.body}');
        }
      }
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text("오류"),
            content: new Text("제목과 내용을 비워두지 마세요!"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }


  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}
