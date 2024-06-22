import 'dart:convert';

import 'package:church/widgets/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => AnnouncementsState();
}

class AnnouncementsState extends State<Announcements> {
  String? userToken;
  dynamic userData;
  int numOfPostsPerPage = 10;
  bool isLastPage = false;
  int pageNum = 0;
  bool loading = false;
  int nextPageTrigger = 3;
  List<dynamic> posts = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    getUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    getAllAnnouncements();
  }

  Future<void> getAllAnnouncements([bool reloadFirstPage = false]) async {
    if (loading || (isLastPage && !reloadFirstPage)) return;

    setState(() {
      loading = true;
      if (reloadFirstPage == true) {
        pageNum = 0;
      }
    });

    try {
      if (mounted) {}
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/post?skip=${pageNum * numOfPostsPerPage}&limit=$numOfPostsPerPage'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userToken!
        },
      );
      if (response.statusCode == 200) {
        List responseList = jsonDecode(response.body)['allPosts'];
        if (mounted) {
          setState(() {
            isLastPage = responseList.length < numOfPostsPerPage;
            pageNum++;
            if (reloadFirstPage == true) {
              posts = responseList;
            } else {
              posts.addAll(responseList);
            }
          });
        }
      } else {
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
                    title: Text(e.toString().contains('ClientException')
                        ? 'مفيش نت'
                        : 'حصل مشكلة'),
                    content: Text(e.toString().contains('ClientException')
                        ? 'اتأكد ان النت شغال وجرب تاني'
                        : 'حصل مشكلة في السيرفر'),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('تمام'))
                    ],
                  ),
                ));
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500 && !loading) {
      getAllAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: RefreshIndicator(
        onRefresh: getAllAnnouncements,
        child: loading == true && pageNum == 0
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + (isLastPage ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Post(
                        body: posts[index],
                        index: index,
                        getAllAnnouncements: getAllAnnouncements,
                      ));
                }),
      ),
    ));
  }
}
