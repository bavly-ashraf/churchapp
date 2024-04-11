import 'package:church/screens/reservations.dart';
import 'package:flutter/material.dart';

class Hall extends StatelessWidget{
    const Hall({super.key, required this.hallName});

    final String hallName;

    @override
    Widget build(BuildContext context){
      void openHallReservation(){
        Feedback.forTap(context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Reservations(hallName: hallName)));
      }

      return GestureDetector(
        onTap: openHallReservation,
        child: (
          Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                Icon(Icons.church_rounded, size: 50, color: Theme.of(context).primaryColor),
                const SizedBox(height: 10),
                Text(hallName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ]),
          )
        ),
      );
    }
}