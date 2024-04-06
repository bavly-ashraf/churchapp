import 'package:church/screens/homepage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

    final _formKey = GlobalKey<FormState>();

    String? _userName;
    String? _pass;

    void _submit(){
      final form = _formKey.currentState;
      if(form != null && form.validate()){
        form.save();
        // showDialog(
        //   context: context, 
        //   builder: (context) {
        //     return AlertDialog(
        //       title: const Text('تمام عدي'),
        //       content: Text('اسم المستخدم: $_userName و كلمة السر: $_pass'),
        //     );
        //   });
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const Homepage())
          );
      }
    }

    @override
    Widget build(BuildContext context){
      return Scaffold(
        appBar: AppBar(
          title: const Text('سجل دخولك'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body:  Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/church_logo.png',width: 150),
              Form(
                key: _formKey,
                child: Column(
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if(value != null && value.contains('.')){
                        return null;
                      }
                      return 'اكتب اسم المستخدم بشكل صحيح';
                    },
                    onSaved: (newValue) => _userName = newValue,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم'
                    ),
                  ),
                     TextFormField(
                    validator: (value) {
                      if(value != null && value.isNotEmpty){
                        return null;
                      }
                      return 'اكتب كلمة السر';
                    },
                    onSaved: (newValue) => _pass = newValue,
                    decoration: const InputDecoration(
                      labelText: 'كلمة السر'
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('دخول'))
                ],
                ))
            ],
          ),
          )),
      );
    }
}