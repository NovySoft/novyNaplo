import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/subjectColor.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart' as rndColor;
import 'package:novynaplo/helpers/logicAndMath/getRandomBetween.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';

Map<String, int> subjectColorMap = new Map<String, int>();
List<SubjectColor> subjectColorList = [];

Color getColorBasedOnSubject(Subject subject) {
  Color color = Colors.purple;
  int categoryIndex = subjectColorList.indexWhere(
    (element) => element.category == subject.category.name,
  );
  if (subjectColorMap[subject.fullName] == null && categoryIndex != -1) {
    color = Color(subjectColorList[categoryIndex].color);
    subjectColorList.add(SubjectColor(
      id: subject.fullName,
      color: color.value,
      category: subject.category.name,
    ));
    DatabaseHelper.insertColor(
      subject.fullName,
      color.value,
      subject.category.name,
    );
  } else if (subjectColorMap[subject.fullName] == null) {
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
    subjectColorMap[subject.fullName] = color.value;
    subjectColorList.add(SubjectColor(
      id: subject.fullName,
      color: color.value,
      category: subject.category.name,
    ));
    DatabaseHelper.insertColor(
      subject.fullName,
      color.value,
      subject.category.name,
    );
  } else {
    //It already exists, no worries
    color = Color(subjectColorMap[subject.fullName]);
  }
  return color;
}
