import 'package:flutter/material.dart';

class Reservations extends StatelessWidget{
  const Reservations({super.key, required this.hallName});

  final String hallName;
  
  @override
  Widget build(BuildContext context) {

    Future<void> showNewReservationModal() {
            return showModalBottomSheet(context: context, builder: (BuildContext context) {
              return const SizedBox(
                height: 600,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text('test')
                  ]),
                  ),
              );
            });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(hallName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text('مواعيد الحجز في $hallName',
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
            ])
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNewReservationModal,
        child: const Icon(Icons.add),
      ),
    );
  }
  
}