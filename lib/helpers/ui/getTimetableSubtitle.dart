import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

String getTimetableSubtitle(Lesson input) {
  String subtitle = "undefined";
  if (globals.lessonCardSubtitle == "Tanterem") {
    subtitle = input.classroom;
  } else if (globals.lessonCardSubtitle == "Óra témája") {
    subtitle = input.theme;
  } else if (globals.lessonCardSubtitle == "Tanár") {
    //TODO: Lehet, hogy elmaradt az óra...
    if (input.teacher != null || input.teacher != "") {
      subtitle = input.teacher;
    } else {
      subtitle = input.deputyTeacher;
    }
  } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
    String startMinutes;
    if (input.startDate.minute.toString().startsWith("0")) {
      startMinutes = input.startDate.minute.toString() + "0";
    } else {
      startMinutes = input.startDate.minute.toString();
    }
    String endMinutes;
    if (input.endDate.minute.toString().startsWith("0")) {
      endMinutes = input.endDate.minute.toString() + "0";
    } else {
      endMinutes = input.endDate.minute.toString();
    }
    String start = input.startDate.hour.toString() + ":" + startMinutes;
    String end = input.endDate.hour.toString() + ":" + endMinutes;
    subtitle = "$start-$end";
  } else if (globals.lessonCardSubtitle == "Időtartam") {
    String diff =
        input.endDate.difference(input.startDate).inMinutes.toString();
    subtitle = "$diff ${getTranslatedString("min")}";
  }
  if (subtitle == "" || subtitle == null) {
    subtitle = getTranslatedString("unkown");
  }
  if (subtitle.length >= 28) {
    subtitle = subtitle.substring(0, 25);
    subtitle += "...";
  }
  return subtitle;
}
