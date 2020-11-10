import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

String getMarkCardSubtitle({@required Evals eval, int trimLength = 30}) {
  String subtitle = "undefined";
  if (globals.markCardSubtitle == "Téma") {
    if (eval.tema != null && eval.tema != "")
      subtitle = capitalize(eval.tema);
    else
      subtitle = getTranslatedString("unkown");
  } else if (globals.markCardSubtitle == "Tanár") {
    subtitle = eval.tanar;
  } else if (globals.markCardSubtitle == "Súly") {
    subtitle = "${eval.sulySzazalekErteke}%";
  } else if (globals.markCardSubtitle == "Pontos Dátum") {
    subtitle = eval.keszitesDatumaString;
  } else if (globals.markCardSubtitle == "Egyszerűsített Dátum") {
    String year = eval.keszitesDatuma.year.toString();
    String month = eval.keszitesDatuma.month.toString();
    String day = eval.keszitesDatuma.day.toString();
    String hour = eval.keszitesDatuma.hour.toString();
    String minutes = eval.keszitesDatuma.minute.toString();
    String seconds = eval.keszitesDatuma.second.toString();
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
