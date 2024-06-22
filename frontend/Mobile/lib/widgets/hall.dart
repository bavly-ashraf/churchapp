import 'package:http/http.dart' as http;
import 'package:church/screens/reservations.dart';
import 'package:flutter/material.dart';

class Hall extends StatelessWidget {
  const Hall(
      {super.key,
      required this.hallID,
      required this.hallName,
      required this.hallFloor,
      required this.hallBuilding,
      required this.getAllHalls,
      required this.userToken,
      required this.role});

  final String hallID;
  final String hallName;
  final String hallFloor;
  final String hallBuilding;
  final String userToken;
  final String role;
  final Function getAllHalls;

  @override
  Widget build(BuildContext context) {
    void openHallReservation() {
      Feedback.forTap(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Reservations(hallID: hallID, hallName: hallName)));
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
      if (response.statusCode == 200) {
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
                  TextButton(
                      onPressed: () {
                        deleteHall();
                        Navigator.pop(context);
                      },
                      child: const Text('اه')),
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
      onLongPress: role == 'admin' ? deleteHallDialog : null,
      child: (Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.church_rounded,
                    size: 50, color: Theme.of(context).primaryColor),
                const SizedBox(height: 10),
                Text(hallName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  hallFloor,
                  textAlign: TextAlign.center,
                ),
                Text(
                  hallBuilding,
                  textAlign: TextAlign.center,
                )
              ]),
        ),
      )),
    );
  }
}
