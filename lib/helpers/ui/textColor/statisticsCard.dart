import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/subjectColor.dart';

Color getStatisticsCardTextColor({
  @required Evals eval,
}) {
  Color color = Colors.black;
  if (globals.statisticsTextColSubject &&
      globals.statisticsCardTheme == "Dark") {
    if (eval.subject.fullName.toLowerCase() == "-contracted-")
      return Colors.grey[350];

    color = getColorBasedOnSubject(eval.subject);
  } else if (globals.statisticsCardTheme == "Dark") {
    color = Colors.grey[350];
  } else if (globals.statisticsCardTheme == "Subject" &&
      globals.darker &&
      eval.subject.fullName.toLowerCase() == "-contracted-") {
    return Colors.grey[350];
  }
  return color;
}
