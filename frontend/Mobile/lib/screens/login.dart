import 'package:church/screens/homepage.dart';
import 'package:church/screens/signup.dart';
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
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: const Text('تمام عدي', textDirection: TextDirection.rtl,),
              content: Text('اسم المستخدم: $_userName و كلمة السر: $_pass',textDirection: TextDirection.rtl,),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('ارجع')),
                TextButton(onPressed: _goToHompage, child: const Text('كمل')),
              ],
            );
          });
      }
    }

    void _goToHompage(){
        Navigator.pop(context);
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const Homepage())
          );
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
            child: SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/church_logo.png',width: 150),
                Form(
                  key: _formKey,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child:
                  Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if(value != null && value.contains('.')){
                          return null;
                        }
                        return 'اكتب اسم المستخدم صح';
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
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة السر'
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('دخول')),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())),
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