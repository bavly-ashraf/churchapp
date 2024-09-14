import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:church/screens/homepage.dart';
import 'package:church/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userData = prefs.getString('userData');
  await firebaseInit(token);
  await firebaseTokenCheck(userData, token);
  runApp(MyApp(
    token: token,
  ));
}

Future<void> reservationAction(String reservationAction, String? token) async {
  try {
    final response = await http.post(
        Uri.parse('https://churchapp-tstf.onrender.com/reservation/confirmation'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!
        },
        body: jsonEncode(<String, bool>{
          'confirmAction': reservationAction == 'confirm' ? true : false
        }));
    switch (response.statusCode) {
      case 200:
        {
          if (navigatorKey.currentState!.mounted) {
            Navigator.pop(navigatorKey.currentState!.context);
          }
        }
      default:
        {
          print(response);
        }
    }
  } catch (e) {
    print(e);
  }
}

Future<dynamic> showReservationDialog(
    RemoteMessage message, String? token) async {
  return navigatorKey.currentState!.push(MaterialPageRoute(
      builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(message.notification!.title!),
            content: Text(message.notification!.body!),
            actions: [
              TextButton(
                  onPressed: () => reservationAction('confirm', token),
                  child: const Text('أكد الحجز')),
              TextButton(
                  onPressed: () => reservationAction('cancel', token),
                  child: const Text('الغي الحجز')),
            ],
          ))));
}

Future<void> firebaseInit(String? token) async {
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.subscribeToTopic('all');
  await FirebaseMessaging.instance.requestPermission(provisional: true);

  ///////////////////////////////// Notification observables (Foreground and background) ////////////////////////////////////
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      displayNotification(
          message.notification!.title!, message.notification!.body!);
      if (message.data.containsKey('reservationID')) {
        showReservationDialog(message, token!);
      }
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data.containsKey('reservationID')) {
      showReservationDialog(message, token);
    }
  });
  RemoteMessage? fromTerminatedStateMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (fromTerminatedStateMessage != null) {
    showReservationDialog(fromTerminatedStateMessage, token);
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  displayNotification(
      message.notification!.title!, message.notification!.body!);
}

///////////////////////////////// Notification on foreground handling /////////////////////////////////////////
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> displayNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'churchApp1', // Provide a unique channel ID
    'churchApp', // Provide a unique channel name
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title, // Notification title
    body, // Notification body
    platformChannelSpecifics,
  );
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////// Firebase Token Check /////////////////////////////////////////////////
Future<void> firebaseTokenCheck(String? userData, String? token) async {
  if (userData != null && token != null) {
    final decodedUserData = jsonDecode(userData);
    if (decodedUserData['firebaseToken'] == null ||
        decodedUserData['firebaseToken'] !=
            FirebaseMessaging.instance.getToken()) {
      await saveToken(token);
    }
  }
}

Future<void> saveToken(String token) async {
  try {
    final fbToken = await FirebaseMessaging.instance.getToken();
    final response = await http.post(
        Uri.parse('https://churchapp-tstf.onrender.com/user/fb-token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token
        },
        body: jsonEncode(<String, String>{'fbToken': fbToken!}));
    switch (response.statusCode) {
      case 201:
        {
          print('success');
        }
        break;
      default:
        print('error ${response.statusCode}');
    }
  } catch (e) {
    print(e);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Saint Mary Church',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffdc143c)),
          useMaterial3: true,
          textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme)),
      // check if there's token in shared preferences and if true open homepage else open login page
      home: token == null ? const LoginPage() : const Homepage(),
    );
  }
}
