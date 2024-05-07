import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationsStatus extends StatefulWidget {
  const ReservationsStatus(
      {super.key, required this.hallID, required this.hallName});

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
  bool loading = false;
  String loadingAction = '';

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
      setState(() {
        loading = true;
      });
      final response = await http.get(
        Uri.parse(role == 'user'
            ? 'https://churchapp-tstf.onrender.com/reservation/user/${widget.hallID}'
            : 'https://churchapp-tstf.onrender.com/reservation/pending/${widget.hallID}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userToken!
        },
      );
      switch (response.statusCode) {
        case 200:
          {
            setState(() {
              reservations = jsonDecode(response.body)["foundedReservations"];
              loading = false;
            });
          }
          break;
        default:
          showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
      }
    } catch (e) {
      if (e.toString().contains('ClientException')) {
        showDefaultMessage('مفيش نت', 'اتأكد ان النت شغال وجرب تاني');
      } else {
        showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
      }
    }
  }

  Future<void> changeStatus(String reservationID, String newStatus) async {
    try {
      setState(() {
        loadingAction = reservationID;
      });
      final response = await http.post(
          Uri.parse(
              'https://churchapp-tstf.onrender.com/reservation/status/$reservationID'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          },
          body: jsonEncode({"status": newStatus}));
      setState(() {
        loadingAction = '';
      });
      switch (response.statusCode) {
        case 200:
          {
            getAllReservations();
          }
          break;
        case 404:
          {
            showDefaultMessage(
                'القاعة محجوزة', 'للأسف القاعة محجوزة في الميعاد دة');
          }
          break;
        default:
          showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
      }
    } catch (e) {
      setState(() {
        loadingAction = '';
      });
      if (e.toString().contains('ClientException')) {
        showDefaultMessage('مفيش نت', 'اتأكد ان النت شغال وجرب تاني');
      } else {
        showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
      }
    }
  }

  Future<void> showConfirmationMessage(String reservationID, String newStatus) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
              textDirection: ui.TextDirection.rtl,
              child: AlertDialog(
                title: newStatus == 'Approved'
                    ? const Text(
                        'تأكيد الحجز',
                        textAlign: ui.TextAlign.center,
                      )
                    : const Text(
                        'رفض الحجز',
                        textAlign: ui.TextAlign.center,
                      ),
                content: newStatus == 'Approved'
                    ? const Text('متأكد انك عايز توافق عالحجز دة؟')
                    : const Text('متأكد انك عايز ترفض الحجز دة؟'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => {
                            changeStatus(reservationID, newStatus),
                            Navigator.pop(context),
                          },
                      child: const Text('اه')),
                  TextButton(
                      onPressed: () => {
                            Navigator.pop(context),
                          },
                      child: const Text('لا'))
                ],
              ));
        });
  }

  Future<void> showDefaultMessage(String title, String content,
      [bool closeAll = false]) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                    onPressed: () => {
                          Navigator.pop(context),
                          if (closeAll == true) {Navigator.pop(context)}
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
        body: RefreshIndicator(
          onRefresh: getAllReservations,
          child: Column(children: [
            const Text(
              'حالة الحجوزات',
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: reservations.length,
                        itemBuilder: (BuildContext context, int index) => Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(3, 10, 3, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.timer,
                                      size: 60,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          reservations[index]['reason'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(reservations[index]
                                                  ['startTime'])),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '${DateFormat('hh:mm a').format(DateTime.parse(reservations[index]['startTime']))} - ${DateFormat('hh:mm a').format(DateTime.parse(reservations[index]['endTime']))}',
                                        ),
                                        if (role == 'admin') ...[
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(reservations[index]['reserver']
                                              ['username'])
                                        ]
                                      ],
                                    ),
                                    reservations[index]['status'] ==
                                                'Pending' &&
                                            role == 'admin'
                                        ? loadingAction ==
                                                reservations[index]['_id']
                                            ? const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    30, 0, 30, 0),
                                                child:
                                                    CircularProgressIndicator())
                                            : Row(
                                                children: <Widget>[
                                                  IconButton(
                                                      onPressed: () =>
                                                          loadingAction ==
                                                                  reservations[
                                                                          index]
                                                                      ['_id']
                                                              ? null
                                                              : showConfirmationMessage(
                                                                  reservations[
                                                                          index]
                                                                      ['_id'],
                                                                  'Approved'),
                                                      tooltip: 'موافقة',
                                                      icon: const Icon(
                                                        Icons
                                                            .check_circle_outline_outlined,
                                                        size: 40,
                                                        color: Colors.green,
                                                      )),
                                                  IconButton(
                                                      onPressed: () =>
                                                          loadingAction ==
                                                                  reservations[
                                                                          index]
                                                                      ['_id']
                                                              ? null
                                                              : showConfirmationMessage(
                                                                  reservations[
                                                                          index]
                                                                      ['_id'],
                                                                  'Rejected'),
                                                      tooltip: 'رفض',
                                                      icon: const Icon(
                                                        Icons.cancel_outlined,
                                                        size: 40,
                                                        color: Colors.red,
                                                      )),
                                                ],
                                              )
                                        : reservations[index]['status'] ==
                                                    'Pending' &&
                                                role == 'user'
                                            ? const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 5, 0),
                                                child: Text(
                                                  'مستني',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 20),
                                                ))
                                            : reservations[index]['status'] ==
                                                    'Rejected'
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 5, 0),
                                                    child: Text(
                                                      'اترفض',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 25),
                                                    ))
                                                : reservations[index]
                                                            ['status'] ==
                                                        'Approved'
                                                    ? const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 5, 0),
                                                        child: Text(
                                                          'اتقبل',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 25),
                                                        ))
                                                    : Container(),
                                  ],
                                ),
                              ),
                            )),
              ),
            ),
          ]),
        ));
  }
}
