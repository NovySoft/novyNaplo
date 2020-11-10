import 'package:intl/intl.dart';
import 'package:novynaplo/global.dart' as globals;

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

extension MyInt on int {
  String intToTHEnding() {
    int input = this;
    String number = input.toString();
    if (globals.language == "hu") return number + ".";
    if (number.endsWith("1")) {
      return number + "st";
    }
    if (number.endsWith("2")) {
      return number + "nd";
    }
    if (number.endsWith("3")) {
      return number + "rd";
    }
    return number + "th";
  }
}
