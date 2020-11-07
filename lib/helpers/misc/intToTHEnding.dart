import 'package:novynaplo/global.dart' as globals;

String intToTHEnding(int input) {
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
