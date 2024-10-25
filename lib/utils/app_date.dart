import 'package:intl/intl.dart';

class AppDate {
  String getCurrentDateTime() {
    final DateTime now = DateTime.now();
    final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy HH:mm:ss');
    return dateTimeFormat.format(now);
  }

  DateTimeResult parseDateTime(String? dateTimeString) {
    if (dateTimeString == null) return DateTimeResult(null, null, null);

    try {
      final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy HH:mm:ss');
      DateTime dateTime = dateTimeFormat.parse(dateTimeString);

      DateTime date = DateTime(dateTime.year, dateTime.month, dateTime.day);
      String time = DateFormat('HH:mm:ss').format(dateTime);

      return DateTimeResult(dateTime, date, time);
    } catch (e) {
      return DateTimeResult(null, null, null);
    }
  }
}

class DateTimeResult {
  final DateTime? fullDateTime;
  final DateTime? date;
  final String? time;

  DateTimeResult(this.fullDateTime, this.date, this.time);
}
