import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;

Color getTimetableCardColor({@required Lesson lesson, @required int index}) {
  Color color = Colors.purple;
  if (globals.timetableCardTheme == "Véletlenszerű") {
    if (index >= marksPage.colors.length) {
      color = getRandomColors(1)[0];
      marksPage.colors.add(color);
    } else {
      color = marksPage.colors[index];
    }
  } else if (globals.timetableCardTheme == "Dark") {
    color = Color(0xFF212121);
  } else if (globals.timetableCardTheme == "Subject") {
    color = getColorBasedOnSubject(lesson.subject);
  }
  return color;
}
