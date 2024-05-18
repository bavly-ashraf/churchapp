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
      required this.index,
      this.attachments,
      required this.getAllAnnouncements});

  final dynamic body;
  final int index;
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
    if(!mounted) return;
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    setState(() {
      userId = userData['_id'];
      postUserId = widget.body['creator']['_id'];
    });
    getPostReacts();
  }

    Future<void> getPostReacts() async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://churchapp-tstf.onrender.com/react/${widget.body['_id']}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          });
      if (response.statusCode == 200) {
        List<dynamic>? reacts = jsonDecode(response.body)['reacts'];
        String? selectedReact = jsonDecode(response.body)['isReacted'];
          // getReactsData(reacts, selectedReact);
          if(mounted){
          setState(() {
            allReacts = reacts;
            react = selectedReact;
          });
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
                    title: Text(e.toString().contains('ClientException')?'مفيش نت':'حصل مشكلة'),
                    content: Text(e.toString().contains('ClientException')? 'اتأكد ان النت شغال وجرب تاني':'حصل مشكلة في السيرفر'),
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
          Uri.parse(
              'https://churchapp-tstf.onrender.com/post/${widget.body['_id']}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          });
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          widget.getAllAnnouncements(true);
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
                    title: Text(e.toString().contains('ClientException')?'مفيش نت':'حصل مشكلة'),
                    content: Text(e.toString().contains('ClientException')? 'اتأكد ان النت شغال وجرب تاني':'حصل مشكلة في السيرفر'),
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
          Uri.parse(
              'https://churchapp-tstf.onrender.com/react/${widget.body['_id']}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          },
          body: jsonEncode(<String, String>{'react': react!}));
      if (response.statusCode == 201) {
        getPostReacts();
      } else if (response.statusCode == 200) {
        setState(() {
          react = null;
        });
        getPostReacts();
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
                    title: Text(e.toString().contains('ClientException')?'مفيش نت':'حصل مشكلة'),
                    content: Text(e.toString().contains('ClientException')? 'اتأكد ان النت شغال وجرب تاني':'حصل مشكلة في السيرفر'),
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

  Widget reactIcon(String react, Color color, double size) {
    switch (react) {
      case 'Like':
        return Icon(
          Icons.thumb_up,
          color: color,
          size: size,
        );
      case 'Love':
        return Icon(
          Icons.favorite,
          color: color,
          size: size,
        );
      case 'Dislike':
        return Icon(
          Icons.thumb_down,
          color: color,
          size: size,
        );
      case 'Sad':
        return Icon(
          Icons.heart_broken,
          color: color,
          size: size,
        );
      default:
        return Container();
    }
  }

  String reactText(String react) {
    switch (react) {
      case 'Like':
        return 'عجبني';
      case 'Love':
        return 'عجبني اوي';
      case 'Dislike':
        return 'مش موافق';
      case 'Sad':
        return 'حزين';
      default:
        throw Exception('Please provide react');
    }
  }

  Future<void> _showReacts() {
    return showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: LayoutBuilder(
              builder: (context, constraints) => AlertDialog(
                title: const Text('الريأكتات', textAlign: TextAlign.center),
                content: SizedBox(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxHeight * 0.8,
                  child: ListView.separated(
                    itemBuilder: (context, index) => ListTile(
                      leading: reactIcon(allReacts[index]['react'],
                          Theme.of(context).primaryColor, 30),
                      title: Text(
                        allReacts[index]['creator']['username'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(reactText(allReacts[index]['react'])),
                    ),
                    itemCount: allReacts.length,
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('تمام'))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return (Card(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Row(
            textDirection: ui.TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    textDirection: ui.TextDirection.rtl,
                    children: <Widget>[
                      const SizedBox(
                        width: 10,
                      ),
                      const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/church_logo.png'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            widget.body['creator']['username'],
                            textScaler: const TextScaler.linear(1.2),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateFormat('dd/MM/yyyy hh:mm a').format(
                              DateTime.parse(widget.body['createdAt'])
                                  .toLocal()))
                        ],
                      )
                    ],
                  ),
                ],
              ),
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
          const Divider(
            indent: 10,
            endIndent: 10,
          ),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(children: <Widget>[
                  allReacts != null && allReacts.isNotEmpty
                      ? Row(
                          textDirection: ui.TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            TextButton(
                                onPressed: _showReacts,
                                child: Text('${allReacts.length} ريأكت'))
                          ],
                        )
                      : Container(),
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
                    ],
                  ),
                ])),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0))
        ],
      ),
    ));
  }
}
