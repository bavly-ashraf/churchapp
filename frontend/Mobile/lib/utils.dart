
/// Example event class.
class Event {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String reserver;
  final String id;
  final String userId;

  const Event(this.title,this.startTime,this.endTime,this.reserver,this.id,this.userId);

  @override
  String toString() => title;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
