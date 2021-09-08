import 'package:intl/intl.dart';
import 'package:novynaplo/global.dart' as globals;

extension MyDateTime on DateTime {
  bool isSameDay(DateTime other) {
    return this.day == other.day &&
        this.month == other.month &&
        this.year == other.year;
  }

  ///Return date in yyyy-MM-dd
  String toDayOnlyString() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(this);
  }

  ///Return date in yyyy-MM-dd hh:mm:ss
  String toHumanString() {
    DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    return formatter.format(this);
  }
}

bool isSameDay(DateTime one, DateTime other) {
  return one.day == other.day &&
      one.month == other.month &&
      one.year == other.year;
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

  String intToEsEnding() {
    int input = this;
    String number = input.toString();
    if (globals.language == "en") return number + "s";
    if (number.endsWith("1") ||
        number.endsWith("2") ||
        number.endsWith("4") ||
        number.endsWith("7") ||
        number.endsWith("9") ||
        number.endsWith("10") ||
        number.endsWith("40") ||
        number.endsWith("50") ||
        number.endsWith("70") ||
        number.endsWith("90")) {
      return number + "es";
    }
    if (number.endsWith("3") ||
        number.endsWith("8") ||
        number.endsWith("20") ||
        number.endsWith("30") ||
        number.endsWith("60") ||
        number.endsWith("80") ||
        number.endsWith("100")) {
      return number + "as";
    }
    if (number.endsWith("5")) {
      return number + "ös";
    }
    if (number.endsWith("6")) {
      return number + "os";
    }
    if (number == "0") {
      return number + "ás";
    }
    return number;
  }
}

String intToTHEnding(input) {
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
