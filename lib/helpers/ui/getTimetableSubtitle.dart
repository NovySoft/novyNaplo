import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

String getTimetableSubtitle(Lesson input) {
  String subtitle = "undefined";
  if (globals.lessonCardSubtitle == "Tanterem") {
    subtitle = input.teremNeve;
  } else if (globals.lessonCardSubtitle == "Óra témája") {
    subtitle = input.tema;
  } else if (globals.lessonCardSubtitle == "Tanár") {
    //TODO: Lehet, hogy elmaradt az óra...
    if (input.tanarNeve != null || input.tanarNeve != "") {
      subtitle = input.tanarNeve;
    } else {
      subtitle = input.helyettesTanarNeve;
    }
  } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
    String startMinutes;
    if (input.kezdetIdopont.minute.toString().startsWith("0")) {
      startMinutes = input.kezdetIdopont.minute.toString() + "0";
    } else {
      startMinutes = input.kezdetIdopont.minute.toString();
    }
    String endMinutes;
    if (input.vegIdopont.minute.toString().startsWith("0")) {
      endMinutes = input.vegIdopont.minute.toString() + "0";
    } else {
      endMinutes = input.vegIdopont.minute.toString();
    }
    String start = input.kezdetIdopont.hour.toString() + ":" + startMinutes;
    String end = input.vegIdopont.hour.toString() + ":" + endMinutes;
    subtitle = "$start-$end";
  } else if (globals.lessonCardSubtitle == "Időtartam") {
    String diff =
        input.vegIdopont.difference(input.kezdetIdopont).inMinutes.toString();
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
