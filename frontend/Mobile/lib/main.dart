import 'package:church/screens/homepage.dart';
import 'package:church/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
  runApp(MyApp(token: token,));
}

class MyApp extends StatelessWidget {
   const MyApp({super.key, this.token});


  final String? token;



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saint Mary Church',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffdc143c)),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(
          Theme.of(context).textTheme
        )
      ),
      // check if there's token in shared preferences and if true open homepage else open login page
      home: token == null ? const LoginPage() : const Homepage(),
    );
  }
}