import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Post extends StatefulWidget {
  const Post({super.key, required this.body, this.attachments});

  final dynamic body;
  final List<String>? attachments;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  String? userToken;
  dynamic userData;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    print(widget.body['creator']['_id']);
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
                        backgroundImage: AssetImage('assets/images/church_logo.png'),
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
                          Text(DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(widget.body['createdAt'])))
                        ],
                      )
                    ],
                  ),
                ],
              ),
              // visible only to post creator
              // (userData["_id"] == widget.body["creator"])?
              IconButton(onPressed: ()=>0, icon: const Icon(Icons.delete))
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
                child: Row(
                  textDirection: ui.TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        onPressed: () => 0,
                        icon: const Icon(Icons.thumb_up_outlined),
                        color: Theme.of(context).primaryColor,
                        tooltip: 'عجبني'),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () => 0,
                        icon: const Icon(Icons.favorite_border_outlined),
                        color: Theme.of(context).primaryColor,
                        tooltip: 'عجبني اوي'),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () => 0,
                        icon: const Icon(Icons.thumb_down_outlined),
                        color: Theme.of(context).primaryColor,
                        tooltip: 'مش موافق'),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () => 0,
                        icon: const Icon(Icons.heart_broken_outlined),
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
                )),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0))
        ],
      ),
    ));
  }
}
