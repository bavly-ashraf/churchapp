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
    bool loading = false;

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
      if(mounted){
      setState(() {
        loading = true;
      });
      }
      final response = await http.get(
        Uri.parse('https://churchapp-tstf.onrender.com/hall'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userToken!
        },
      );
      if(response.statusCode == 200){
        if(mounted){
        setState(() {
          hallNames = jsonDecode(response.body)['halls'];
          loading = false;
        });
        }
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

    @override
    Widget build(BuildContext context){
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: getAllHalls,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: (
              loading == true?
              const Center(
                child: CircularProgressIndicator(),
              ) :
              GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: hallNames.length,
              itemBuilder: (context , index)=> Hall(hallID: hallNames[index]['_id'], hallName: hallNames[index]['name'],hallFloor: hallNames[index]['floor'] ?? '',hallBuilding: hallNames[index]['building'] ?? '', getAllHalls: getAllHalls,userToken: userToken!, role: userData['role'],)
              )
            ),
          ),
        ),
      );
    }
}