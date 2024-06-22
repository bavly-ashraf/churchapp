import 'dart:convert';

import 'package:church/screens/homepage.dart';
import 'package:church/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final url = Uri.parse('http://localhost:3000/user/login');

  String? _userName;
  String? _pass;
  bool loading = false;

  void _submit() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      login();
    }
  }

  Future<void> login() async {
    try {
      setState(() {
        loading = true;
      });
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _userName!,
          'password': _pass!,
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse.containsKey('token')){
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', decodedResponse['token']);
          await prefs.setString('userData',jsonEncode(decodedResponse['user']));
          _goToHompage();
        }
      } else if(response.statusCode == 404 || response.statusCode == 400){
        setState(() {
          loading = false;
        });
                  if (mounted) {
            showDialog(
                context: context,
                builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: const Text('حصل مشكلة'),
                        content: const Text('بيانات غلط'),
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
      setState(() {
        loading = false;
      });
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

  void _goToHompage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Homepage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل دخولك'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/church_logo.png', width: 150),
              Form(
                  key: _formKey,
                  child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              }
                              return 'اكتب اسم المستخدم';
                            },
                            onSaved: (newValue) => _userName = newValue,
                            decoration: const InputDecoration(
                                labelText: 'اسم المستخدم'),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              }
                              return 'اكتب كلمة السر';
                            },
                            onSaved: (newValue) => _pass = newValue,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: 'كلمة السر'),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                              onPressed: loading? null: _submit, child: loading? const Padding( padding: EdgeInsets.all(8) ,child: CircularProgressIndicator()): const Text('دخول')),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignupPage())),
                              child: const Text('اعمل حساب جديد'))
                        ],
                      )))
            ],
          ),
        ),
      )),
    );
  }
}
