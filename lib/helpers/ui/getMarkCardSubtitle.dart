import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

String getMarkCardSubtitle({@required Evals eval, int trimLength = 30}) {
  String subtitle = "undefined";
  if (globals.markCardSubtitle == "Téma") {
    if (eval.theme != null && eval.theme != "")
      subtitle = capitalize(eval.theme);
    else
      subtitle = getTranslatedString("unknown");
  } else if (globals.markCardSubtitle == "Tanár") {
    subtitle = eval.teacher;
  } else if (globals.markCardSubtitle == "Súly") {
    subtitle = "${eval.weight}%";
  } else if (globals.markCardSubtitle == "Pontos Dátum") {
    subtitle = eval.createDate.toHumanString();
  } else if (globals.markCardSubtitle == "Egyszerűsített Dátum") {
    subtitle = eval.createDate.toHumanString().split(" ")[0];
  }
  if (subtitle == "" || subtitle == null) {
    subtitle = getTranslatedString("unknown");
  }
  return subtitle;
}
