import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';

Color getNoticesAndEventsCardColor(int index) {
  Color color = Colors.purple;
  if (globals.noticesAndEventsCardTheme == "Véletlenszerű") {
    if (marks.colors.length <= index) {
      color = getRandomColors(1)[0];
    } else {
      color = marks.colors[index];
    }
  } else if (globals.noticesAndEventsCardTheme == "Dark") {
    color = Color(0xFF212121);
  }
  return color;
}
