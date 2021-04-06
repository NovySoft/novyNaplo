import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart' as rndColor;
import 'package:novynaplo/helpers/logicAndMath/getRandomBetween.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';

Map<String, int> subjectColorMap = new Map<String, int>();

Color getColorBasedOnSubject(Subject subject) {
  Color color = Colors.purple;
  if (subjectColorMap[subject.category.name] == null) {
    //Create color and add it to db
    bool found = false;
    for (var i = 0; i < rndColor.myListOfRandomColors.length; i++) {
      if (!subjectColorMap.containsValue(
        rndColor.myListOfRandomColors[i].value,
      )) {
        color = rndColor.myListOfRandomColors[i];
        found = true;
        break;
      }
    }
    if (!found) {
      print("Not found");
      color = Color.fromARGB(
        255,
        getRandomIntBetween(
          0,
          255,
        ),
        getRandomIntBetween(
          0,
          255,
        ),
        getRandomIntBetween(
          0,
          255,
        ),
      );
    }
    subjectColorMap[subject.category.name] = color.value;
    DatabaseHelper.insertColor(
      subject.category.name,
      color.value,
      subject.fullName,
    );
  } else {
    //It already exists, no worries
    color = Color(subjectColorMap[subject.category.name]);
  }
  return color;
}
