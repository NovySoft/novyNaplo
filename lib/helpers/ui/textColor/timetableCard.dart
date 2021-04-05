import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/subjectColor.dart';

Color getTimetableCardTextColor({@required Lesson lesson}) {
  Color color = Colors.black;
  if (globals.timetableTextColSubject && globals.timetableCardTheme == "Dark") {
    color = getColorBasedOnSubject(lesson.subject.fullName.toLowerCase());
  } else if (globals.timetableCardTheme == "Dark") {
    color = Colors.grey[350];
  }
  return color;
}
