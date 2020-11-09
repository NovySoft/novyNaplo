import 'package:intl/intl.dart';

extension MyDateTime on DateTime {
  bool isSameDay(DateTime other) {
    return this.day == other.day &&
        this.month == other.month &&
        this.year == other.year;
  }

  String toKretaDateString() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(this);
  }
}
