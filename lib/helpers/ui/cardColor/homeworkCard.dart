import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;

Color getHomeworkCardColor({@required Homework hw, @required int index}) {
  Color color = Colors.red;
  if (globals.homeworkCardTheme == "Véletlenszerű") {
    if (marks.colors.length <= index) {
      color = getRandomColors(1)[0];
    } else {
      color = marks.colors[index];
    }
  } else if (globals.homeworkCardTheme == "Dark") {
    color = Color(0xFF212121);
  } else if (globals.homeworkCardTheme == "Subject") {
    color = getColorBasedOnSubject(hw.subject);
  }
  return color;
}
