import 'package:flutter/material.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/getRandomBetween.dart';
import 'package:novynaplo/helpers/ui/cardColor/timetableCard.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart' as rndColor;

Color getTimetableCardTextColor({@required Lesson lesson}) {
  Color color = Colors.black;
  if (globals.timetableTextColSubject) {
    if (subjectColorMap[lesson.subject.name.toLowerCase()] == null) {
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
      subjectColorMap[lesson.subject.name.toLowerCase()] = color.value;
      DatabaseHelper.insertColor(
        lesson.subject.name.toLowerCase(),
        color.value,
      );
    } else {
      //It already exists, no worries
      color = Color(subjectColorMap[lesson.subject.name.toLowerCase()]);
    }
  } else if (globals.timetableCardTheme == "Dark") {
    color = Colors.grey[350];
  }
  return color;
}
