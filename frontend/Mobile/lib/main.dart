import 'package:church/screens/homepage.dart';
import 'package:church/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: ('token'.isEmpty)? const Homepage() : const LoginPage(),
    );
  }
}