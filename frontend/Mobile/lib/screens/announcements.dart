import 'dart:convert';

import 'package:church/widgets/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => _Announcements();
}

class _Announcements extends State<Announcements> {
  String? userToken;
  dynamic userData;
  List<dynamic> body = [];
  // final List<String> attachments = ['assets/images/church_logo.png'];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    getAllAnnouncements();
  }

  Future<void> getAllAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/post?skip=0&limit=10'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userToken!
        },
      );
      if(response.statusCode == 200){
        setState(() {
          body = jsonDecode(response.body)['allPosts'];
        });
      }else{
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
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
                  textDirection: TextDirection.rtl,
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
    return (Scaffold(
      body: ListView.builder(
        itemCount: body.length,
        itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Post(
              body: body[index],
              // attachments: attachments,
            )),
      ),
    ));
  }
}
