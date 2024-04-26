import 'package:http/http.dart' as http;
import 'package:church/screens/reservations.dart';
import 'package:flutter/material.dart';

class Hall extends StatelessWidget {
  const Hall({super.key, required this.hallID , required this.hallName, required this.getAllHalls, required this.userToken});

  final String hallID;
  final String hallName;
  final String userToken;
  final Function getAllHalls;

  @override
  Widget build(BuildContext context) {
    void openHallReservation() {
      Feedback.forTap(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Reservations(hallName: hallName)));
    }

    Future<void> deleteHall() async {
          // try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/hall/$hallID'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userToken
        },
      );
      if(response.statusCode == 200){
        getAllHalls();
      }
    // else{
    //     if (mounted) {
    //       showDialog(
    //           context: context,
    //           builder: (context) => Directionality(
    //                 textDirection: TextDirection.rtl,
    //                 child: AlertDialog(
    //                   title: const Text('حصل مشكلة'),
    //                   content: const Text('حصل مشكلة في السيرفر'),
    //                   actions: <Widget>[
    //                     TextButton(
    //                         onPressed: () => Navigator.pop(context),
    //                         child: const Text('تمام'))
    //                   ],
    //                 ),
    //               ));
    //     }
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     showDialog(
    //         context: context,
    //         builder: (context) => Directionality(
    //               textDirection: TextDirection.rtl,
    //               child: AlertDialog(
    //                 title: const Text('حصل مشكلة'),
    //                 content: const Text('حصل مشكلة في السيرفر'),
    //                 actions: <Widget>[
    //                   TextButton(
    //                       onPressed: () => Navigator.pop(context),
    //                       child: const Text('تمام'))
    //                 ],
    //               ),
    //             ));
    //   }
    // }
    }

    Future<void> deleteHallDialog() async {
      showDialog(
          context: context,
          builder: (context) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('متأكد؟'),
                content: const Text('متأكد انك عايز تمسح القاعة دي؟'),
                actions: <Widget>[
                  TextButton(onPressed: (){
                    deleteHall();
                    Navigator.pop(context);
                  }, child: const Text('اه')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('لا')),
                ],
              ),
            );
          });
    }

    return GestureDetector(
      onTap: openHallReservation,
      onLongPress: deleteHallDialog,
      child: (Card(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.church_rounded,
                  size: 50, color: Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              Text(hallName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold))
            ]),
      )),
    );
  }
}
