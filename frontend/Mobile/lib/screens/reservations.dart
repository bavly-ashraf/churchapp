import 'dart:convert';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:church/screens/reservations_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';

class Reservations extends StatefulWidget {
  const Reservations({super.key, required this.hallID, required this.hallName});

  final String hallID;
  final String hallName;

  @override
  State<Reservations> createState() => _Reservations();
}

class _Reservations extends State<Reservations> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  final _newReservationFormKey = GlobalKey<FormState>();
  String? _newReservationReason;
  final TextEditingController _selectedDateController = TextEditingController();
  final TextEditingController _selectedEndDateController =
      TextEditingController();
  final TextEditingController _selectedStartTimeController =
      TextEditingController();
  final TextEditingController _selectedEndTimeController =
      TextEditingController();
  DateTime? _selectedDate;
  bool _isFixed = false;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? userToken;
  dynamic userData;
  String role = 'user';
  List<dynamic> initialEventList = [];
  bool loading = false;
  bool loadingAction = false;

  @override
  void initState() {
    super.initState();
    getUserData();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    userData = jsonDecode(prefs.getString('userData')!);
    role = userData['role'];
    await getEventsAPI(kFirstDay, kLastDay);
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
  }

  List<Event> _getEventsForDay(DateTime day) {
    final List<Event> eventsList = initialEventList
        .where((element) =>
            element['startTime'].split('T')[0] ==
            day.toIso8601String().split('T')[0])
        .toList()
        .map((el) => Event(
            el['reason'],
            tz.TZDateTime.from(DateTime.parse(el['startTime']),
                tz.getLocation('Africa/Cairo')),
            tz.TZDateTime.from(
                DateTime.parse(el['endTime']), tz.getLocation('Africa/Cairo')),
            el['reserver']['username'],
            el['_id'],
            el['reserver']['_id']))
        .toList();
    return eventsList;
  }

  Future<void> getEventsAPI(DateTime firstDay, DateTime lastDay) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(
      Uri.parse(
          'https://churchapp-tstf.onrender.com/reservation/calendar/${widget.hallID}?firstDay=${firstDay.toIso8601String()}&lastDay=${lastDay.toIso8601String()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': userToken!
      },
    );
    setState(() {
      initialEventList = jsonDecode(response.body)['foundedReservations'];
      loading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void deleteEventDialog(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              title: const Text('مسح الحجز'),
              content: const Text('متأكد انك عايز تمسح الحجز؟'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => {Navigator.pop(context), _deleteEvent(id)},
                    child: const Text('اه')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('لا')),
              ],
            ),
          );
        });
  }

  Future<void> _deleteEvent(String id) async {
    final response = await http.delete(
      Uri.parse('https://churchapp-tstf.onrender.com/reservation/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': userToken!
      },
    );
    if (response.statusCode == 200) {
      await getEventsAPI(kFirstDay, kLastDay);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  Future<void> _reserve() async {
    final form = _newReservationFormKey.currentState;
    if (form != null && form.validate()) {
      DateTime today = DateTime.now();
      DateTime todayDateOnly =
          DateTime(today.year, today.month, today.day, 0, 0, 0);
      if (_selectedDate!.isBefore(todayDateOnly) ||
          (_selectedEndTime!.hour <= _selectedStartTime!.hour &&
              _selectedEndTime!.minute <= _selectedStartTime!.minute) ||
          (_isFixed && _selectedEndDate!.isBefore(_selectedDate!))) {
        showDefaultMessage(
            'الميعاد غلط', 'من فضلك اتأكد ان التاريخ والميعاد مكتوبين صح');
      } else {
        form.save();
        await _createNewReservation();
      }
    }
  }

  Future<void> _createNewReservation() async {
    DateTime finalStartDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute);
    DateTime finalEndDate = DateTime(
        _isFixed ? _selectedEndDate!.year : _selectedDate!.year,
        _isFixed ? _selectedEndDate!.month : _selectedDate!.month,
        _isFixed ? _selectedEndDate!.day : _selectedDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute);
    try {
      final response = await http.post(
          Uri.parse('https://churchapp-tstf.onrender.com/reservation/${widget.hallID}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': userToken!
          },
          body: jsonEncode({
            "reason": _newReservationReason,
            "startTime": finalStartDate.toUtc().toIso8601String(),
            "endTime": finalEndDate.toUtc().toIso8601String(),
            "isFixed": _isFixed,
          }));
      switch (response.statusCode) {
        case 201:
          {
            setState(() {
              _selectedDateController.text = '';
              _selectedEndDateController.text = '';
              _selectedStartTimeController.text = '';
              _selectedEndTimeController.text = '';
              _selectedDate = null;
              _selectedEndDate = null;
              _selectedStartTime = null;
              _selectedEndTime = null;
            });
            showDefaultMessage(
                'مستني الموافقة',
                'طلب الحجز اتبعت ومستني الموافقة تقدر تتابع الحجز في صفحة متباعة الحجوزات',
                true);
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
      if (e.toString().contains('ClientException')) {
        showDefaultMessage('مفيش نت', 'اتأكد ان النت شغال وجرب تاني');
      } else {
        showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
      }
    }
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

  Future<void> showNewReservationModal() {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20.0)
                .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: createNewReservation(),
              ),
            ),
          );
        });
  }

  Future<void> _selectDate(BuildContext context, String date) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    switch (date) {
      case 'start':
        {
          if (picked != null &&
              '${picked.day}/${picked.month}/${picked.year}' !=
                  _selectedDateController.text &&
              picked != _selectedDate) {
            setState(() {
              _selectedDateController.text =
                  '${picked.day}/${picked.month}/${picked.year}';
              _selectedDate = picked;
            });
          }
        }
        break;
      case 'end':
        {
          if (picked != null &&
              '${picked.day}/${picked.month}/${picked.year}' !=
                  _selectedEndDateController.text &&
              picked != _selectedEndDate) {
            setState(() {
              _selectedEndDateController.text =
                  '${picked.day}/${picked.month}/${picked.year}';
              _selectedEndDate = picked;
            });
          }
        }
    }
  }

  Future<void> _selectTime(BuildContext context, String time) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    switch (time) {
      case 'start':
        {
          if (picked != null &&
              picked.format(context) != _selectedStartTimeController.text &&
              picked != _selectedStartTime) {
            setState(() {
              _selectedStartTimeController.text = picked.format(context);
              _selectedStartTime = picked;
            });
          }
        }
        break;
      case 'end':
        {
          if (picked != null &&
              picked.format(context) != _selectedEndTimeController.text &&
              picked != _selectedEndTime) {
            setState(() {
              _selectedEndTimeController.text = picked.format(context);
              _selectedEndTime = picked;
            });
          }
        }
    }
  }

  Widget createNewReservation() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Text(
                'حجز جديد',
                style: TextStyle(
                    fontSize: 25, color: Theme.of(context).primaryColor),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Form(
                        key: _newReservationFormKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                if (value != '') {
                                  return null;
                                }
                                return 'من فضلك اكتب سبب الحجز';
                              },
                              onSaved: (newReservationReason) =>
                                  _newReservationReason = newReservationReason,
                              decoration: const InputDecoration(
                                hintText: 'اكتب سبب الحجز',
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context, 'start');
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                    textDirection: ui.TextDirection.ltr,
                                    textAlign: TextAlign.end,
                                    decoration: const InputDecoration(
                                      labelText: 'اختار اليوم',
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    validator: (value) {
                                      if (value != '') {
                                        return null;
                                      }
                                      return 'من فضلك اختار اليوم';
                                    },
                                    controller: _selectedDateController),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectTime(context, 'start');
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                    textDirection: ui.TextDirection.ltr,
                                    textAlign: TextAlign.end,
                                    decoration: const InputDecoration(
                                      labelText: 'اختار وقت البداية',
                                      suffixIcon: Icon(Icons.timer_outlined),
                                    ),
                                    validator: (value) {
                                      if (value != '') {
                                        return null;
                                      }
                                      return 'من فضلك اختار وقت البداية';
                                    },
                                    controller: _selectedStartTimeController),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectTime(context, 'end');
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                    textDirection: ui.TextDirection.ltr,
                                    textAlign: TextAlign.end,
                                    decoration: const InputDecoration(
                                      labelText: 'اختار وقت النهاية',
                                      suffixIcon: Icon(Icons.timer_outlined),
                                    ),
                                    validator: (value) {
                                      if (value != '') {
                                        return null;
                                      }
                                      return 'من فضلك اختار وقت النهاية';
                                    },
                                    controller: _selectedEndTimeController),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('ميعاد ثابت؟ '),
                                Checkbox(
                                    value: _isFixed,
                                    onChanged: (bool? value) {
                                      setModalState(() {
                                        _isFixed = value!;
                                      });
                                    }),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            (_isFixed
                                ? GestureDetector(
                                    onTap: () {
                                      _selectDate(context, 'end');
                                    },
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                          textDirection: ui.TextDirection.ltr,
                                          textAlign: TextAlign.end,
                                          decoration: const InputDecoration(
                                            labelText: 'اختار اخر يوم',
                                            suffixIcon:
                                                Icon(Icons.calendar_today),
                                          ),
                                          validator: (value) {
                                            if (value != '') {
                                              return null;
                                            }
                                            return 'من فضلك اختار اخر يوم';
                                          },
                                          controller:
                                              _selectedEndDateController),
                                    ),
                                  )
                                : Container()),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                onPressed: loadingAction == true
                                    ? null
                                    : () {
                                        setModalState(() {
                                          loadingAction = true;
                                        });
                                        _reserve()
                                            .then((value) => setModalState(() {
                                                  loadingAction = false;
                                                }));
                                      },
                                child: loadingAction == true
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator())
                                    : const Text('حجز القاعة'))
                          ],
                        ),
                      ))),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.hallName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReservationsStatus(
                          hallID: widget.hallID,
                          hallName: widget.hallName,
                        ))),
            icon: const Icon(Icons.pending_actions),
            tooltip: 'متابعة الحجوزات',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await getEventsAPI(kFirstDay, kLastDay);
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        },
        child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            child: Column(children: [
              Text(
                'مواعيد الحجز في ${widget.hallName} (${_calendarFormat.name == 'month' ? 'الشهر' : _calendarFormat.name == 'week' ? 'الاسبوع' : 'النص شهر'} دة)',
                textDirection: ui.TextDirection.rtl,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (loading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else ...[
                TableCalendar<Event>(
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.saturday,
                  calendarStyle: const CalendarStyle(
                    // Use `CalendarStyle` to customize the UI
                    outsideDaysVisible: false,
                  ),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: AlertDialog(
                                          title: const Text(
                                            'تفاصيل الحجز',
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  const Text('سبب الحجز: '),
                                                  Text(
                                                    value[index].title,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            ui.FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  const Text('من: '),
                                                  Text(
                                                    DateFormat('hh:mm a').format(
                                                        tz.TZDateTime.from(
                                                            value[index]
                                                                .startTime,
                                                            tz.getLocation(
                                                                'Africa/Cairo'))),
                                                    textDirection:
                                                        ui.TextDirection.ltr,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            ui.FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  const Text('الى: '),
                                                  Text(
                                                    DateFormat('hh:mm a').format(
                                                        tz.TZDateTime.from(
                                                            value[index]
                                                                .endTime,
                                                            tz.getLocation(
                                                                'Africa/Cairo'))),
                                                    textDirection:
                                                        ui.TextDirection.ltr,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            ui.FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  const Text('الحاجز: '),
                                                  Text(
                                                    value[index].reserver,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            ui.FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('تمام'))
                                          ],
                                        ),
                                      );
                                    });
                              },
                              onLongPress: (role == 'admin' ||
                                      userData['_id'] == value[index].userId)
                                  ? () => deleteEventDialog(value[index].id)
                                  : null,
                              title: Text('${value[index]}'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ]
            ])),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNewReservationModal,
        tooltip: 'حجز ميعاد جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
