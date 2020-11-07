import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

String getMarkCardSubtitle({@required Evals eval, int trimLength = 30}) {
  String subtitle = "undefined";
  if (globals.markCardSubtitle == "Téma") {
    if (eval.theme != null && eval.theme != "")
      subtitle = capitalize(eval.theme);
    else
      subtitle = getTranslatedString("unkown");
  } else if (globals.markCardSubtitle == "Tanár") {
    subtitle = eval.teacher;
  } else if (globals.markCardSubtitle == "Súly") {
    subtitle = eval.weight;
  } else if (globals.markCardSubtitle == "Pontos Dátum") {
    subtitle = eval.createDateString;
  } else if (globals.markCardSubtitle == "Egyszerűsített Dátum") {
    String year = eval.createDate.year.toString();
    String month = eval.createDate.month.toString();
    String day = eval.createDate.day.toString();
    String hour = eval.createDate.hour.toString();
    String minutes = eval.createDate.minute.toString();
    String seconds = eval.createDate.second.toString();
    subtitle = "$year-$month-$day $hour:$minutes:$seconds";
  }
  if (subtitle == "" || subtitle == null) {
    subtitle = getTranslatedString("unkown");
  }
  if (subtitle.length >= trimLength) {
    subtitle = subtitle.substring(0, trimLength - 3);
    subtitle += "...";
  }
  return subtitle;
}
