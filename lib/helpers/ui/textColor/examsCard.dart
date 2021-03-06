import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/global.dart' as globals;

Color getExamsCardTextColor({@required Exam exam}) {
  Color color = Colors.black;
  if (globals.examsTextColSubject && globals.examsCardTheme == "Dark") {
    color = getColorBasedOnSubject(exam.subject);
  } else if (globals.examsCardTheme == "Dark") {
    color = Colors.grey[350];
  }
  return color;
}
