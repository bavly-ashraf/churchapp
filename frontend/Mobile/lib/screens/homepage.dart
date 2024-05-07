import 'dart:convert';

import 'package:church/screens/announcements.dart';
import 'package:church/screens/halls.dart';
import 'package:church/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _Homepage();
}

class _Homepage extends State<Homepage> with SingleTickerProviderStateMixin {
  //tab navigation variables
  late TabController controller = TabController(length: 2, vsync: this);

  //new announcement variables
  final _newAnnounceFormKey = GlobalKey<FormState>();
  final _newHallFormKey = GlobalKey<FormState>();
  final GlobalKey<AnnouncementsState> _announcementKey =
      GlobalKey<AnnouncementsState>();
  final GlobalKey<HallsState> _hallKey = GlobalKey<HallsState>();
  String? _newAnnounce;
  String? _newHall;

  //sharedPref variables
  dynamic userData;
  String? userToken;
  String userName = 'ازيك';
  String role = 'user';

  // check user role (user || admin)
  bool showFab = false;

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
      userName = userData['username'];
      role = userData['role'];
      showFab = (role == 'user') ? false : true;
    });
  }

  Future<void> _uploadPost() async {
    final form = _newAnnounceFormKey.currentState;
    if (form != null && form.validate() && userToken != null) {
      form.save();
      try {
        final response = await http.post(
            Uri.parse('https://churchapp-tstf.onrender.com/post'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': userToken!
            },
            body: jsonEncode(<String, String>{'body': _newAnnounce!}));
        if (response.statusCode == 201 && mounted) {
          Navigator.pop(context);
          _announcementKey.currentState?.getAllAnnouncements(true);
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
  }

  Future<void> _uploadHall() async {
    final form = _newHallFormKey.currentState;
    if (form != null && form.validate() && userToken != null) {
      form.save();
      try {
        final response = await http.post(
            Uri.parse('https://churchapp-tstf.onrender.com/hall'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': userToken!
            },
            body: jsonEncode(<String, String>{'name': _newHall!}));
        if (response.statusCode == 201 && mounted) {
          Navigator.pop(context);
          _hallKey.currentState?.getAllHalls();
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
  }

  Future<void> createNew() {
    switch (controller.index) {
      case 0:
        return showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(20.0)
                    .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: createNewAnnouncement(),
                  ),
                ),
              );
            });
      case 1:
        return showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(20.0)
                    .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: createNewHall(),
                  ),
                ),
              );
            });
    }
    throw const FormatException('Error: modal not found');
  }

  Widget createNewAnnouncement() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
              'تنبيه جديد',
              style: TextStyle(
                  fontSize: 25, color: Theme.of(context).primaryColor),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Form(
                      key: _newAnnounceFormKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (value) {
                              if (value != '') {
                                return null;
                              }
                              return 'من فضلك اكتب تنبيه';
                            },
                            onSaved: (newAnnounce) =>
                                _newAnnounce = newAnnounce,
                            decoration: const InputDecoration(
                              hintText: 'اكتب تنبيه جديد',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              onPressed: _uploadPost,
                              child: const Text('نشر التنبيه'))
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }

  Widget createNewHall() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
              'قاعة جديد',
              style: TextStyle(
                  fontSize: 25, color: Theme.of(context).primaryColor),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Form(
                      key: _newHallFormKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (value) {
                              if (value != '') {
                                return null;
                              }
                              return 'من فضلك اكتب اسم القاعة';
                            },
                            onSaved: (newHall) => _newHall = newHall,
                            decoration: const InputDecoration(
                              hintText: 'اكتب اسم القاعة',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              onPressed: _uploadHall,
                              child: const Text('اضافة القاعة'))
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onExit(bool didpop, BuildContext context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: const Text('خروج'),
                  content: const Text('متاكد انك عايز تخرج؟'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop'),
                        child: const Text('اه')),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('لا'))
                  ],
                ));
          });
    }

    Future<void> removeToken() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userData');
    }

    void logout() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: const Text('تسجيل خروج'),
                  content: const Text('متاكد انك عايز تسجل خروج؟'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigator.pushNamedAndRemoveUntil(
                          //     context, '/', (route) => false);
                          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => const LoginPage()), (route)=> false);
                          //don't forget to remove token from shared preferences
                          removeToken();
                        },
                        child: const Text('اه')),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('لا'))
                  ],
                ));
          });
    }

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) => onExit(didPop, context),
        child: Scaffold(
            appBar: AppBar(
              // title: Text('ازيك ${userName == null? '':'يا $userName'}'),
              title: Text(userName),
              // title: const Text('ازيك يا يوزر'),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                IconButton(
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                  tooltip: 'تسجيل الخروج',
                ),
                const SizedBox(width: 10),
              ],
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            // don't forget to show it for admins only!
            floatingActionButton: showFab
                ? FloatingActionButton(
                    onPressed: createNew,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add),
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Material(
              child: TabBar(
                tabs: const <Tab>[
                  Tab(
                    icon: Icon(Icons.home),
                    text: 'التنبيهات',
                  ),
                  Tab(
                    icon: Icon(Icons.lock_clock),
                    text: 'حجز القاعات',
                  ),
                ],
                controller: controller,
              ),
            ),
            body: TabBarView(
              controller: controller,
              children: <Widget>[
                Announcements(
                  key: _announcementKey,
                ),
                Halls(
                  key: _hallKey,
                )
              ],
            )));
  }
}
