import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:church/screens/reservations_status.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';

class Reservations extends StatefulWidget {
  const Reservations({super.key, required this.hallID , required this.hallName});

  final String hallID;
  final String hallName;

  @override
  State<Reservations> createState() => _Reservations();
}

class _Reservations extends State<Reservations> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final _newReservationFormKey = GlobalKey<FormState>();
  String? _newReservationReason;
  final TextEditingController _selectedDateController = TextEditingController();
  final TextEditingController _selectedStartTimeController =
      TextEditingController();
  final TextEditingController _selectedEndTimeController =
      TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? userToken;
  dynamic userData;

  @override
  void initState() {
    super.initState();
    getUserData();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
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
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
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
              _selectedEndTime!.minute <= _selectedStartTime!.minute)) {
        showDefaultMessage('الميعاد غلط','من فضلك اتأكد ان التاريخ والميعاد مكتوبين صح');
      } else {
        form.save();
        _createNewReservation();
      }
    }
  }

  Future<void> _createNewReservation() async {
    DateTime finalStartDate = DateTime(_selectedDate!.year,_selectedDate!.month,_selectedDate!.day, _selectedStartTime!.hour, _selectedStartTime!.minute);
    DateTime finalEndDate = DateTime(_selectedDate!.year,_selectedDate!.month,_selectedDate!.day, _selectedEndTime!.hour, _selectedEndTime!.minute);
    try{
    final response = await http.post(Uri.parse('https://churchapp-tstf.onrender.com/reservation/${widget.hallID}'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userToken!
    },
    body: jsonEncode({
      "reason": _newReservationReason,
      "startTime": finalStartDate.toIso8601String(),
      "endTime": finalEndDate.toIso8601String(),
    })
    );
    switch(response.statusCode){
      case 201: {
        showDefaultMessage('مستني الموافقة', 'طلب الحجز اتبعت ومستني الموافقة تقدر تتابع الحجز في صفحة متباعة الحجوزات', true);
      } break;
      case 404: {
        showDefaultMessage('القاعة محجوزة', 'للأسف القاعة محجوزة في الميعاد دة');
      } break;
      default:
        showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
    }
    }catch(e){
        showDefaultMessage('حصل مشكلة', 'حصل مشكلة في السيرفر');
    }
  }

  Future<void> showDefaultMessage(String title, String content, [bool closeAll = false]) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
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

  Future<void> showNewReservationModal() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20.0)
                .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: 600,
              child: Center(
                child: createNewReservation(),
              ),
            ),
          );
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
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
                    textDirection: TextDirection.rtl,
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
                              _selectDate(context);
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                  textDirection: TextDirection.ltr,
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
                                  textDirection: TextDirection.ltr,
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
                                  textDirection: TextDirection.ltr,
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
                          ElevatedButton(
                              onPressed: _reserve,
                              child: const Text('حجز القاعة'))
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
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
      body: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(10),
          child: Column(children: [
            Text(
              'مواعيد الحجز في ${widget.hallName} (${_calendarFormat.name == 'month' ? 'الشهر' : _calendarFormat.name == 'week' ? 'الاسبوع' : 'النص شهر'} دة)',
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TableCalendar<Event>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.saturday,
              calendarStyle: const CalendarStyle(
                // Use `CalendarStyle` to customize the UI
                outsideDaysVisible: false,
              ),
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
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
                          onTap: () => print('${value[index]}'),
                          title: Text('${value[index]}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: showNewReservationModal,
        tooltip: 'حجز ميعاد جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
