import 'package:church/screens/homepage.dart';
import 'package:church/screens/login.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget{
  const Splash({super.key, required this.token});

  final String? token;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash>{

  @override
  void initState(){
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async{
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget.token == null? const LoginPage() : const Homepage()));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xffdc143c),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

        Image.asset('assets/images/church_logo.png', width: 300,),
        const SizedBox(height: 20,),
        const Text('Church app', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),)
          ]
      ),
      )
    );
  }
}