import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/global.dart' as globals;

Color getMarkCardTextColor({@required Evals eval}) {
  Color color = Colors.black;
  if (globals.marksTextColSubject && globals.markCardTheme == "Dark") {
    color = getColorBasedOnSubject(eval.subject.fullName.toLowerCase());
  } else if (globals.markCardTheme == "Dark") {
    color = Colors.grey[350];
  }
  return color;
}
