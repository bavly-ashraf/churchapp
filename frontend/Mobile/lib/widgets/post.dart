import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Post extends StatefulWidget {
  const Post(
      {super.key,
      required this.body,
      this.attachments,
      required this.getAllAnnouncements});

  final dynamic body;
  final Function getAllAnnouncements;
  final List<String>? attachments;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  String? userToken;
  dynamic userData;
  String? userId;
  String? postUserId;
  String? react;
  dynamic allReacts;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    setState(() {
      userId = userData['_id'];
      postUserId = widget.body['creator']['_id'];
      if (widget.body['postReacts'] != null &&
          widget.body['postReacts'].length > 0) {
            allReacts = widget.body['postReacts'];
        var userReact = widget.body['postReacts'].firstWhere(
            (el) => el['creator'] == userData['_id'],
            orElse: () => null);
        if (userReact != null) {
          react = userReact['react'];
        }
      }
    });
  }

  Future<void> _deletePostDialog() async {
    showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              title: const Text('متأكد؟'),
              content: const Text('متأكد انك عايز تمسح التنبيه دة؟'),
              actions: <Widget>[
                TextButton(onPressed: _deletePost, child: const Text('اه')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('لا')),
              ],
            ),
          );
        });
  }

  Future<void> _deletePost() async {
    try {
      final response = await http.delete(
          Uri.parse('http://localhost:3000/post/${widget.body['_id']}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          });
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          widget.getAllAnnouncements();
        }
      } else {
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) => Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('حصل مشكلة'),
                      content: const Text('حصل مشكلة في السيرفر'),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('تمام'))
                      ],
                    ),
                  ));
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: AlertDialog(
                    title: const Text('حصل مشكلة'),
                    content: const Text('حصل مشكلة في السيرفر'),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('تمام'))
                    ],
                  ),
                ));
      }
    }
  }

  Future<void> _postReact() async {
    try {
      final response = await http.post(
          Uri.parse('http://localhost:3000/react/${widget.body['_id']}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          },
          body: jsonEncode(<String, String>{'react': react!}));
      if (response.statusCode == 201) {

      } else if (response.statusCode == 200) {
        setState(() {
          react = null;
        });
      } else {
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) => Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('حصل مشكلة'),
                      content: const Text('حصل مشكلة في السيرفر'),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('تمام'))
                      ],
                    ),
                  ));
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: AlertDialog(
                    title: const Text('حصل مشكلة'),
                    content: const Text('حصل مشكلة في السيرفر'),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('تمام'))
                    ],
                  ),
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // const TextStyle txtStyle = TextStyle(fontSize: 10);

    return (Card(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 10,
                      ),
                      const CircleAvatar(
                        // backgroundImage: widget.attachments != null &&
                        //         widget.attachments!.isNotEmpty
                        //     ? AssetImage(widget.attachments![0])
                        //     : const AssetImage('assets/images/church_logo.png'),
                        backgroundImage:
                            AssetImage('assets/images/church_logo.png'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.body['creator']['username'],
                            textScaler: const TextScaler.linear(1.2),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateFormat('dd/MM/yyyy hh:mm a')
                              .format(DateTime.parse(widget.body['createdAt'])))
                        ],
                      )
                    ],
                  ),
                ],
              ),
              // visible only to post creator
              // (userData["_id"] == widget.body["creator"])?
              if (userId == postUserId)
                IconButton(
                    onPressed: _deletePostDialog,
                    icon: const Icon(Icons.delete_outline))
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
              child: Text(
                widget.body["body"],
                style: const TextStyle(fontSize: 20),
                textDirection: ui.TextDirection.rtl,
              ),
            ),
          ),
          // widget.attachments != null && widget.attachments!.isNotEmpty
          //     ? Padding(
          //         padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          //         child: Row(
          //             textDirection: TextDirection.rtl,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: <Widget>[
          //               Image.asset(
          //                 widget.attachments![0],
          //                 width: 100,
          //               ),
          //             ]),
          //       )
          //     : Container(),
          const Divider(
            indent: 10,
            endIndent: 10,
          ),
          // GestureDetector(
          //   onTap: () => print('working!!!'),
          //   child: const Padding(
          //       padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          //       child: Row(
          //         textDirection: TextDirection.rtl,
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: <Widget>[Text('5'),Text('تفاعل ')],
          //       )),
          // ),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: <Widget>[
                    allReacts != null?
                    Row(
                      textDirection: ui.TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextButton(onPressed: ()=> 0, child: Text('${allReacts.length} ريأكت'))
                      ],
                    ): Container(),
                    Row(
                    textDirection: ui.TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          onPressed: () {
                            setState(() {
                              react = 'Like';
                            });
                            _postReact();
                          },
                          icon: react == 'Like'
                              ? const Icon(Icons.thumb_up)
                              : const Icon(Icons.thumb_up_outlined),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'عجبني'),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              react = 'Love';
                            });
                            _postReact();
                          },
                          icon: react == 'Love'
                              ? const Icon(Icons.favorite_rounded)
                              : const Icon(Icons.favorite_border_outlined),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'عجبني اوي'),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              react = 'Dislike';
                            });
                            _postReact();
                          },
                          icon: react == 'Dislike'
                              ? const Icon(Icons.thumb_down)
                              : const Icon(Icons.thumb_down_outlined),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'مش موافق'),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              react = 'Sad';
                            });
                            _postReact();
                          },
                          icon: react == 'Sad'
                              ? const Icon(Icons.heart_broken)
                              : const Icon(Icons.heart_broken_outlined),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'حزين'),
                      // ElevatedButton.icon(
                      //     onPressed: () => 0,
                      //     icon: const Icon(Icons.thumb_up_outlined),
                      //     label: const Text(
                      //       'عجبني',
                      //       style: txtStyle,
                      //     )),
                      // const SizedBox(width: 10),
                      // ElevatedButton.icon(
                      //     onPressed: () => 0,
                      //     icon: const Icon(Icons.favorite_border_outlined),
                      //     label: const Text(
                      //       'عجبني اوي',
                      //       style: txtStyle,
                      //     )),
                      // const SizedBox(width: 10),
                      // ElevatedButton.icon(
                      //     onPressed: () => 0,
                      //     icon: const Icon(Icons.thumb_down_outlined),
                      //     label: const Text(
                      //       'معجبنيش',
                      //       style: txtStyle,
                      //     )),
                      // const SizedBox(width: 10),
                      // ElevatedButton.icon(
                      //     onPressed: () => 0,
                      //     icon: const Icon(Icons.heart_broken_outlined),
                      //     label: const Text(
                      //       'حزين',
                      //       style: txtStyle,
                      //     )),
                    ],
                  ),
                  ]
                )),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0))
        ],
      ),
    ));
  }
}
