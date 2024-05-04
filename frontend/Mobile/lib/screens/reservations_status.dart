import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationsStatus extends StatefulWidget {
   const ReservationsStatus({super.key, required this.hallID ,required this.hallName});

  final String hallID;
  final String hallName;

  @override
  State<ReservationsStatus> createState() => _Reservations();
}

class _Reservations extends State<ReservationsStatus> {
  dynamic reservations = [];
  dynamic userData;
  String? userToken;
  String role = 'user';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

    Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    role = userData['role'];
  getAllReservations();
  }
    Future<void> getAllReservations() async {
    try {
      final response = await http.get(
        Uri.parse( role == 'user'?
            'https://churchapp-tstf.onrender.com/reservation/user/${widget.hallID}':
            'https://churchapp-tstf.onrender.com/reservation/pending/${widget.hallID}'
            ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userToken!
        },
      );
      switch(response.statusCode){
        case 200: {
          setState(() {
            reservations = jsonDecode(response.body)["foundedReservations"];
          });
        } break;
        default: 
        showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
      }

    } catch (e) {
        showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
    }
  }



  Future<void> showDefaultMessage(String title, String content, [bool closeAll = false]) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              title: Text(title, textAlign: TextAlign.center,),
              content:
                   Text(content),
              actions: <Widget>[
                TextButton(
                    onPressed: () => {
                      Navigator.pop(context),
                      if(closeAll == true){
                      Navigator.pop(context)
                      }
                      },
                    child: const Text('تمام'))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //Don't forget loading && sort && approve, reject
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('حالة الحجوزات في ${widget.hallName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
            const Text(
              'حالة الحجوزات',
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: reservations.length,

                  itemBuilder: (BuildContext context, int index) => 
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3, 10, 3, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Icon(Icons.timer,size: 60,),
                        Column(
                          children: <Widget>[
                            Text('${DateFormat('dd/MM/yyyy hh:mm a').format(
                              DateTime.parse(reservations[index]['startTime']))} - ${DateFormat('hh:mm a').format(
                              DateTime.parse(reservations[index]['endTime']))}',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                            const SizedBox(height: 8,),
                            Text(reservations[index]['reason']),
                            const SizedBox(height: 8,),
                            Text(reservations[index]['reserver']['username'])
                          ],
                        ),
                        reservations[index]['status'] == 'Pending' && role == 'admin'?
                        const Row(
                          children: <Widget>[
                        IconButton(onPressed: null, tooltip: 'موافقة' , icon: Icon(Icons.check_circle_outline_outlined,size: 40, color: Colors.green,)),
                        IconButton(onPressed: null, tooltip: 'رفض' , icon: Icon(Icons.cancel_outlined, size: 40, color: Colors.red,)),
                          ],
                        ) : 
                        reservations[index]['status'] == 'Pending' && role == 'user'?
                        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0), child: Text('مستني', style: TextStyle(color: Colors.blue, fontSize: 20),)) : 
                        reservations[index]['status'] == 'Rejected'? 
                        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0), child: Text('اترفض', style: TextStyle(color: Colors.red, fontSize: 25),)) : 
                        reservations[index]['status'] == 'Approved'?
                        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0), child: Text('اتقبل', style: TextStyle(color: Colors.green, fontSize: 25),)) : Container(),
                      ],),
                  ),
                )),
              ),
            ),
            ])
            );
  }
}
