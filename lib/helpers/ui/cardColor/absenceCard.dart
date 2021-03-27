import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/absence.dart';

Color getAbsenceCardColor(Absence absence) {
  Color color = Colors.purple;
  if (absence.justificationState == "Igazolando") {
    color = Colors.yellow;
  } else if (absence.justificationState == "Igazolatlan") {
    color = Colors.red;
  } else if (absence.justificationState == "Igazolt") {
    color = Colors.green;
  }
  return color;
}
