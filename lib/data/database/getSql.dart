import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/helpers/data/decryptionHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/data/database/mainSql.dart' as mainSql;
import 'package:novynaplo/global.dart' as globals;

Future<List<Average>> getAllAverages() async {
  FirebaseCrashlytics.instance.log("getAllAverages");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT * FROM Average GROUP BY subject ORDER BY databaseId',
  );

  return List.generate(maps.length, (i) {
    Average temp = new Average();
    temp.databaseId = maps[i]['databaseId'];
    temp.subject = maps[i]['subject'];
    temp.value = maps[i]['ownValue'];
    return temp;
  });
}

Future<Homework> getHomeworkById(int id) async {
  //TODO If not found fetch it with networkHelper
  /*final Database db = await mainSql.database;
  var answer = await db.rawQuery(
      "select * from Homework where id = ? or databaseId = ?;", [id, id]);
  Homework output = new Homework();
  if (answer.length == 0) return output;
  output.databaseId = answer[0]['databaseId'];
  output.id = answer[0]['id'];
  output.classGroupId = answer[0]['classGroupId'];
  output.subject = answer[0]['subject'];
  output.teacher = answer[0]['teacher'];
  output.content = answer[0]['content'];
  output.givenUpString = answer[0]['givenUpString'];
  output.dueDateString = answer[0]['dueDateString'];
  output.givenUp = DateTime.parse(output.givenUpString);
  output.dueDate = DateTime.parse(output.dueDateString);
  return output;*/
}

Future<List<Exam>> getAllExams() async {
  FirebaseCrashlytics.instance.log("getAllExams");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT * FROM Exams GROUP BY id, nameOfExam ORDER BY databaseId',
  );

  List<Exam> tempList = List.generate(maps.length, (i) {
    Exam temp = new Exam();
    /* temp.nameOfExam = maps[i]['nameOfExam'];
    temp.typeOfExam = maps[i]['typeOfExam'];
    temp.databaseId = maps[i]['databaseId'];
    temp.id = maps[i]['id'];
    temp.classGroupId = maps[i]['classGroupId'];
    temp.subject = maps[i]['subject'];
    temp.teacher = maps[i]['teacher'];
    temp.dateWriteString = maps[i]['dateWriteString'];
    temp.dateGivenUpString = maps[i]['dateGivenUpString'];
    temp.dateWrite = DateTime.parse(temp.dateWriteString);
    temp.dateGivenUp = DateTime.parse(temp.dateGivenUpString);
    if (temp.dateWrite.add(Duration(days: 7)).isBefore(DateTime.now())) {
      deleteFromDb(temp.databaseId, "Exams");
    }*/
    return temp;
  });
  /*tempList.removeWhere(
      (temp) => temp.dateWrite.add(Duration(days: 7)).isBefore(DateTime.now()));*/
  return tempList;
}
