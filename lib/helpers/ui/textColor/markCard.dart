import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getColorBasedOnEval.dart';

Color getMarkCardTextColor({@required Evals eval}) {
  Color color = Colors.black;
  if (globals.marksTextColSubject && globals.markCardTheme == "Dark") {
    color = getColorBasedOnSubject(eval.subject);
  } else if (globals.marksTextColEval && globals.markCardTheme == "Dark") {
    color = getColorBasedOnEval(eval);
  } else if (globals.markCardTheme == "Dark") {
    color = Colors.grey[350];
  }
  return color;
}
