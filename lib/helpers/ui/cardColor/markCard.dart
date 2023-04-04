import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/helpers/ui/themeHelper.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;
import 'package:novynaplo/helpers/ui/getColorBasedOnEval.dart';

Color getMarkCardColor({@required Evals eval, @required int index}) {
  Color color;
  if (globals.markCardTheme == "Véletlenszerű") {
    if (marks.colors.length <= index) {
      color = getRandomColors(1)[0];
    } else {
      color = marks.colors[index];
    }
  } else if (globals.markCardTheme == "Értékelés nagysága") {
    color = getColorBasedOnEval(eval);
  } else if (globals.markCardTheme == "Egyszínű") {
    color = ThemeHelper().stringToColor(globals.markCardConstColor);
  } else if (globals.markCardTheme == "Színátmenetes") {
    color = ThemeHelper
        .myGradientList[(ThemeHelper.myGradientList.length - index - 1).abs()];
  } else if (globals.markCardTheme == "Dark") {
    color = Color(0xFF212121);
  } else if (globals.markCardTheme == "Subject") {
    color = getColorBasedOnSubject(eval.subject);
  } else {
    color = Colors.red;
  }
  return color;
}
