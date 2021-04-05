import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/global.dart' as globals;

Color getHomeworkCardTextColor({@required Homework hw}) {
  Color color = Colors.black;
  if (globals.homeworkTextColSubject && globals.homeworkCardTheme == "Dark") {
    color = getColorBasedOnSubject(hw.subject.fullName.toLowerCase());
  } else if (globals.homeworkCardTheme == "Dark") {
    color = Colors.grey[350];
  }
  return color;
}
