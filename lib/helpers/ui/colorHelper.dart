import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/helpers/ui/themeHelper.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;

Color getAbsenceCardColor(Absence absence) {
  Color color = Colors.purple;
  if (absence.justificationState == "Igazolando") {
    color = Colors.yellow;
  } else if (absence.justificationState == "Igazolatlan") {
    color = Colors.red;
  } else if (absence.justificationState == "Igazolt") {
    color = Colors.green;
  }
  return color;
}

Color getMarkCardColor({@required Evals eval, @required int index}) {
  Color color;
  if (globals.markCardTheme == "Véletlenszerű") {
    if (marks.colors.length <= index) {
      color = getRandomColors(1)[0];
    } else {
      color = marks.colors[index];
    }
  } else if (globals.markCardTheme == "Értékelés nagysága") {
    if (eval.valueType.name == "Szazalekos") {
      //TODO: Variable percentage limits
      if (eval.numberValue >= 90) {
        color = Colors.green;
      } else if (eval.numberValue >= 75) {
        color = Colors.lightGreen;
      } else if (eval.numberValue >= 60) {
        color = Colors.yellow[800];
      } else if (eval.numberValue >= 40) {
        color = Colors.deepOrange;
      } else {
        color = Colors.red[900];
      }
    } else {
      switch (eval.numberValue) {
        case 5:
          color = Colors.green;
          break;
        case 4:
          color = Colors.lightGreen;
          break;
        case 3:
          color = Colors.yellow[800];
          break;
        case 2:
          color = Colors.deepOrange;
          break;
        case 1:
          color = Colors.red[900];
          break;
        default:
          color = Colors.purple;
          break;
      }
    }
  } else if (globals.markCardTheme == "Egyszínű") {
    color = ThemeHelper().stringToColor(globals.markCardConstColor);
  } else if (globals.markCardTheme == "Színátmenetes") {
    color = ThemeHelper
        .myGradientList[(ThemeHelper.myGradientList.length - index - 1).abs()];
  } else {
    color = Colors.red;
  }
  return color;
}
