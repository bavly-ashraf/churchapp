import 'dart:convert';
import 'package:church/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final url = Uri.parse('https://churchapp-tstf.onrender.com/user/signup');

  String? _userName;
  String? _email;
  String? _mobile;
  String? _pass;
  String? _churchCode;
  bool loading = false;
  // String? _churchCode;

  void _createNewAccount() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      signUp();
      // showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         title: const Text(
      //           'تمام عدي',
      //           textDirection: TextDirection.rtl,
      //         ),
      //         content: Text(
      //           'اسم المستخدم: $_userName و كلمة السر: $_pass والموبايل: $_mobile والايميل: $_email',
      //           textDirection: TextDirection.rtl,
      //         ),
      //         actions: <Widget>[
      //           TextButton(
      //               onPressed: () => Navigator.pop(context),
      //               child: const Text('ارجع')),
      //           TextButton(onPressed: _goToHompage, child: const Text('كمل')),
      //         ],
      //       );
      //     });
    }
  }

  Future<void> signUp() async {
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
          'email': _email!,
          'password': _pass!,
          'mobile': _mobile!,
          'code': _churchCode!
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          loading = false;
        });
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'الحساب اتعمل',
                    textDirection: TextDirection.rtl,
                  ),
                  content: const Text(
                    'من فضلك سجل دخول بحسابك',
                    textDirection: TextDirection.rtl,
                  ),
                  actions: <Widget>[
                    TextButton(onPressed: _goToLogin, child: const Text('كمل')),
                  ],
                );
              });
        }
      } else if(response.statusCode == 403){
        setState(() {
          loading = false;
        });
                  if (mounted) {
            showDialog(
                context: context,
                builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: const Text('كود الكنيسة'),
                        content: const Text('كود الكنيسة غلط'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('تمام'))
                        ],
                      ),
                    ));
          }
      } else {
        setState(() {
          loading = false;
        });
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse.containsKey('message') &&
            decodedResponse['message']
                .toString()
                .contains('duplicate key error')) {
          if (mounted) {
            showDialog(
                context: context,
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                        title: const Text('حصل مشكلة'),
                        content: const Text('الحساب دة موجود فعلا'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('تمام'))
                        ],
                      ),
                ));
          }
        } else {
          if (mounted) {
            showDialog(
                context: context,
                builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: const Text('حصل مشكلة'),
                        content: Text(response.statusCode == 400? 'اتأكد ان البيانات صح واليوزر والباسورد من 3 ل 30 حرف او رقم' : 'حصل مشكلة في السيرفر'),
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

  void _goToLogin() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب جديد'),
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
                                // if (!value.contains('.')) {
                                //   return 'اكتب اسم المستخدم صح';
                                // }
                                return null;
                              }
                              return 'اكتب اسم المستخدم';
                            },
                            onSaved: (newValue) => _userName = newValue,
                            decoration: const InputDecoration(
                                labelText: 'اسم المستخدم'),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'اكتب الايميل صح';
                                }
                                return null;
                              }
                              return 'اكتب الايميل';
                            },
                            onSaved: (newValue) => _email = newValue,
                            decoration:
                                const InputDecoration(labelText: 'الايميل'),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(
                                        r'^(\+201|01|00201)[0-2,5]{1}[0-9]{8}')
                                    .hasMatch(value)) {
                                  return 'اكتب رقم الموبايل صح';
                                }
                                return null;
                              }
                              return 'اكتب رقم الموبايل';
                            },
                            onSaved: (newValue) => _mobile = newValue,
                            decoration: const InputDecoration(
                                labelText: 'رقم الموبايل'),
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
                          TextFormField(
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              }
                              return 'اكتب كود الكنيسة';
                            },
                            onSaved: (newValue) => _churchCode = newValue,
                            decoration:
                                const InputDecoration(labelText: 'كود الكنيسة'),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                              onPressed: loading? null: _createNewAccount,
                              child: loading? const Padding( padding: EdgeInsets.all(8) ,child: CircularProgressIndicator()): const Text('اعمل حساب جديد'))
                        ],
                      )))
            ],
          ),
        ),
      )),
    );
  }
}
