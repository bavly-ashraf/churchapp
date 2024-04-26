import 'package:flutter/material.dart';

class ReservationsStatus extends StatefulWidget {
   const ReservationsStatus({super.key, required this.hallName});

  final String hallName;

  @override
  State<ReservationsStatus> createState() => _Reservations();
}

class _Reservations extends State<ReservationsStatus> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('حالة الحجوزات في ${widget.hallName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(10),
          child: const Column(children: [
            Text(
              'حالة الحجوزات',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),])),
    );
  }
}
