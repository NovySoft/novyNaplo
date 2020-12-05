import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';
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
    subtitle = eval.keszitesDatuma.toHumanString();
  }
  if (subtitle == "" || subtitle == null) {
    subtitle = getTranslatedString("unkown");
  }
  return subtitle;
}
