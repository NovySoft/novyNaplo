import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;

Color getStatiscticsCardColor(
  int index, {
  @required Evals eval,
  @required BuildContext context,
}) {
  Color color = Colors.purple;
  if (globals.statisticsCardTheme == "Véletlenszerű") {
    if (index >= marksPage.colors.length) {
      color = getRandomColors(1)[0];
      marksPage.colors.add(color);
    } else {
      color = marksPage.colors[index];
    }
  } else if (globals.statisticsCardTheme == "Dark") {
    color = Color(0xFF212121);
  } else if (globals.statisticsCardTheme == "Subject") {
    if (eval.subject.fullName.toLowerCase() == "-contracted-")
      return Theme.of(context).primaryColor;
    color = getColorBasedOnSubject(eval.subject);
  }
  return color;
}
