import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;
import '../getRandomColors.dart';

Color getExamsCardColor(int index, {@required Exam exam}) {
  Color color = Colors.purple;
  if (globals.examsCardTheme == "Véletlenszerű") {
    if (marks.colors.length <= index) {
      color = getRandomColors(1)[0];
    } else {
      color = marks.colors[index];
    }
  } else if (globals.examsCardTheme == "Dark") {
    color = Color(0xFF212121);
  } else if (globals.examsCardTheme == "Subject") {
    color = getColorBasedOnSubject(exam.subject.fullName.toLowerCase());
  }
  return color;
}
