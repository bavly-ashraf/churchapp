import 'dart:convert';

import 'package:church/screens/announcements.dart';
import 'package:church/screens/halls.dart';
import 'package:church/screens/login.dart';
import 'package:church/screens/reservations_status.dart';
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
  String? _newHallName;
  String _newHallFloor = 'الدور الأرضي';
  String _newHallBuilding = 'مبنى الخدمات الرئيسي';
  int _count = 0;

  //sharedPref variables
  dynamic userData;
  String? userToken;
  String userName = 'ازيك';
  String role = 'user';

  // check user role (user || admin)
  bool showFab = false;

  // loading variables for disabling when post
  bool loadingPost = false;
  bool loadingHall = false;

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
    if (userData['role'] == 'admin') {
      _getPendingCount();
    }
  }

  Future<void> _getPendingCount() async {
    try {
      final response = await http.get(
          Uri.parse('https://churchapp-tstf.onrender.com/reservation/pending/count'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          });
      if (response.statusCode == 200) {
        int pendingCount =
            jsonDecode(response.body)['foundedReservationsCount'];
        setState(() {
          _count = pendingCount;
        });
      }
    } catch (e) {
      print(e);
    }
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
            body: jsonEncode(<String, String>{
              'name': _newHallName!,
              'floor': _newHallFloor,
              'building': _newHallBuilding
            }));
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
                  height: 300,
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
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
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
                                onPressed: loadingPost == true
                                    ? null
                                    : () {
                                        setModalState(() {
                                          loadingPost = true;
                                        });
                                        _uploadPost()
                                            .then((value) => setModalState(() {
                                                  loadingPost = false;
                                                }));
                                      },
                                child: loadingPost == true
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator())
                                    : const Text('نشر التنبيه'))
                          ],
                        ),
                      ))),
            ],
          ),
        ),
      );
    });
  }

  Widget createNewHall() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
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
                              onSaved: (newHall) => _newHallName = newHall,
                              decoration: const InputDecoration(
                                hintText: 'اكتب اسم القاعة',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SegmentedButton<String>(
                              segments: const <ButtonSegment<String>>[
                                ButtonSegment<String>(
                                    value: 'الدور الأرضي',
                                    label: Text('الدور الأرضي')),
                                ButtonSegment<String>(
                                    value: 'الدور الأول',
                                    label: Text('الدور الأول')),
                                ButtonSegment<String>(
                                    value: 'الدور التاني',
                                    label: Text('الدور التاني')),
                                ButtonSegment<String>(
                                    value: 'الدور التالت',
                                    label: Text('الدور التالت'))
                              ],
                              selected: <String>{_newHallFloor},
                              onSelectionChanged: (Set<String> newSelection) {
                                setModalState(() {
                                  _newHallFloor = newSelection.first;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SegmentedButton<String>(
                              segments: const <ButtonSegment<String>>[
                                ButtonSegment<String>(
                                    value: 'مبنى الخدمات الرئيسي',
                                    label: Text('مبنى الخدمات الرئيسي')),
                                ButtonSegment<String>(
                                    value: 'مبنى الخدمات الصغير',
                                    label: Text('مبنى الخدمات الصغير')),
                              ],
                              selected: <String>{_newHallBuilding},
                              onSelectionChanged: (Set<String> newSelection) {
                                setModalState(() {
                                  _newHallBuilding = newSelection.first;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                                onPressed: loadingHall == true
                                    ? null
                                    : () {
                                        setModalState(() {
                                          loadingHall = true;
                                        });
                                        _uploadHall()
                                            .then((value) => setModalState(() {
                                                  loadingHall = false;
                                                }));
                                      },
                                child: loadingHall == true
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator())
                                    : const Text('اضافة القاعة'))
                          ],
                        ),
                      ))),
            ],
          ),
        ),
      );
    });
  }

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
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (route) => false);
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) => onExit(didPop, context),
        child: Scaffold(
            appBar: AppBar(
              title: Text(userName),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                if (role == 'admin')
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReservationsStatus())),
                    icon: Badge.count(
                      count: _count,
                      isLabelVisible: (_count > 0),
                      child: const Icon(Icons.pending_actions),
                    ),
                    tooltip: 'متابعة الحجوزات',
                  ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                  tooltip: 'تسجيل الخروج',
                ),
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
