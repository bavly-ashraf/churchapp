import 'package:flutter/material.dart';

class Hall extends StatelessWidget{
    const Hall({super.key, required this.hallName});

    final String hallName;

    @override
    Widget build(BuildContext context){
      return GestureDetector(
        onTap: () => print('working $hallName!!'),
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