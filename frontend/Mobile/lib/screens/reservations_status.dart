import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReservationsStatus extends StatefulWidget {
   const ReservationsStatus({super.key, required this.hallName});

  final String hallName;

  @override
  State<ReservationsStatus> createState() => _Reservations();
}

class _Reservations extends State<ReservationsStatus> {
  List<String> reservations = ['',''];
  String role = 'Admin';
  String status = 'Pending';

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
      body: Column(children: [
            const Text(
              'حالة الحجوزات',
              textDirection: TextDirection.rtl,
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
                        const Column(
                          children: <Widget>[
                            Text('ميعاد الحجز',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            SizedBox(height: 8,),
                            Text('سبب الحجز'),
                            SizedBox(height: 8,),
                            Text('الحاجز')
                          ],
                        ),
                        status == 'Pending' && role == 'Admin'?
                        const Row(
                          children: <Widget>[
                        IconButton(onPressed: null, tooltip: 'موافقة' , icon: Icon(Icons.check_circle_outline_outlined,size: 40, color: Colors.green,)),
                        IconButton(onPressed: null, tooltip: 'رفض' , icon: Icon(Icons.cancel_outlined, size: 40, color: Colors.red,)),
                          ],
                        ) : 
                        status == 'Pending' && role == 'User'?
                        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0), child: Text('مستني الموافقة', style: TextStyle(color: Colors.blue, fontSize: 20),)) : 
                        status == 'Rejected'? 
                        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0), child: Text('اترفض', style: TextStyle(color: Colors.red, fontSize: 25),)) : 
                        status == 'Approved'?
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
