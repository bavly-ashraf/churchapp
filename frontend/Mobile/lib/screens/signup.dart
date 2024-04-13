import 'package:church/screens/homepage.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  String? _userName;
  String? _pass;
  String? _churchCode;

  void _createNewAccount() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'تمام عدي',
                textDirection: TextDirection.rtl,
              ),
              content: Text(
                'اسم المستخدم: $_userName و كلمة السر: $_pass وكود الكنيسة: $_churchCode',
                textDirection: TextDirection.rtl,
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ارجع')),
                TextButton(onPressed: _goToHompage, child: const Text('كمل')),
              ],
            );
          });
    }
  }

  void _goToHompage() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Homepage()));
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
                                if(!value.contains('.')){
                                  return 'اكتب اسم المستخدم صح';
                                }
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
                              onPressed: _createNewAccount,
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
