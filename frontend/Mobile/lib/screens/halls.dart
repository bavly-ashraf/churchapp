import 'dart:convert';

import 'package:church/widgets/hall.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Halls extends StatefulWidget{
     const Halls({super.key});

     @override
     State<Halls> createState() => HallsState();
}
class HallsState extends State<Halls>{
    String? userToken;
    dynamic userData;
    dynamic hallNames = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

      Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    getAllHalls();
  }

Future<void> getAllHalls() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/hall'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userToken!
        },
      );
      if(response.statusCode == 200){
        setState(() {
          hallNames = jsonDecode(response.body)['halls'];
        });
      }else{
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
  }

    @override
    Widget build(BuildContext context){
      return Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: (
            GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: hallNames.length,
            itemBuilder: (context , index)=> Hall(hallID: hallNames[index]['_id'], hallName: hallNames[index]['name'], getAllHalls: getAllHalls,userToken: userToken!)
            )
          ),
        ),
      );
    }
}