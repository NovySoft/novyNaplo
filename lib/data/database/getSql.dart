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

Future<List<Homework>> getAllHomework({bool ignoreDue = true}) async {
  FirebaseCrashlytics.instance.log("getAllHw");
  // Get a reference to the database.
  /*final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT * FROM Homework GROUP BY content, id ORDER BY databaseId',
  );

  List<Homework> tempList = List.generate(maps.length, (i) {
    Homework temp = new Homework();
    temp.databaseId = maps[i]['databaseId'];
    temp.id = maps[i]['id'];
    temp.classGroupId = maps[i]['classGroupId'];
    temp.subject = maps[i]['subject'];
    temp.teacher = maps[i]['teacher'];
    temp.content = maps[i]['content'];
    temp.givenUpString = maps[i]['givenUpString'];
    temp.dueDateString = maps[i]['dueDateString'];
    temp.givenUp = DateTime.parse(temp.givenUpString);
    temp.dueDate = DateTime.parse(temp.dueDateString);
    return temp;
  });
  //If we don't ignore the dueDate
  if (ignoreDue == false) {
    tempList.removeWhere((item) {
      //Hide if it doesn't needed
      DateTime afterDue = item.dueDate;
      if (globals.howLongKeepDataForHw != -1) {
        afterDue =
            afterDue.add(Duration(days: globals.howLongKeepDataForHw.toInt()));
        if (afterDue.compareTo(DateTime.now()) < 0) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    });
  }
  return tempList;*/
}

/*Future<List<Lesson>> getAllTimetable() async {
  FirebaseCrashlytics.instance.log("getAllTimetable");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT * FROM Timetable GROUP BY id ORDER BY databaseId',
  );

  List<Lesson> outputTempList = List.generate(maps.length, (i) {
    Lesson temp = new Lesson();
    temp.databaseId = maps[i]['databaseId'];
    temp.id = maps[i]['id'];
    temp.theme = maps[i]['theme'];
    temp.subject = maps[i]['subject'];
    temp.teacher = maps[i]['teacher'];
    temp.name = maps[i]['name'];
    temp.groupName = maps[i]['groupName'];
    temp.classroom = maps[i]['classroom'];
    temp.deputyTeacherName = maps[i]['deputyTeacherName'];
    temp.dogaNames = json.decode(maps[i]['dogaNames']);
    temp.whichLesson = maps[i]['whichLesson'];
    temp.homeWorkId = maps[i]['homeWorkId'];
    temp.teacherHomeworkId = maps[i]['teacherHomeworkId'];
    temp.groupID = maps[i]['groupID'];
    temp.dogaIds = json.decode(maps[i]['dogaIds']);
    temp.homeworkEnabled = maps[i]['homeworkEnabled'] == 0 ? false : true;

    temp.dateString = maps[i]['date'];
    temp.date = DateTime.parse(temp.dateString);

    temp.startDateString = maps[i]['startDate'];
    temp.startDate = DateTime.parse(temp.startDateString);

    temp.endDateString = maps[i]['endDate'];
    temp.endDate = DateTime.parse(temp.endDateString);
    return temp;
  });
  //TODO LOOK INTO THIS
  for (var n in outputTempList) {
    if (n.teacherHomeworkId != null) {
      n.teacherHomework = await getHomeworkById(n.teacherHomeworkId);
    } else if (n.homeWorkId != null) {
      n.teacherHomework = await getHomeworkById(n.homeWorkId);
    }
  }
  return outputTempList;
}*/

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

Future<List<List<Absence>>> getAllAbsencesMatrix() async {
  FirebaseCrashlytics.instance.log("getAllAbsencesMatrix");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT * FROM Absences GROUP BY id ORDER BY databaseId',
  );

  /*List<Absence> tempList = List.generate(maps.length, (i) {
    Absence temp = new Absence();
    temp.databaseId = maps[i]['databaseId'];
    temp.id = maps[i]['id'];
    temp.type = maps[i]['type'];
    temp.typeName = maps[i]['typeName'];
    temp.subject = maps[i]['subject'];
    temp.delayTimeMinutes = maps[i]['delayTimeMinutes'];
    temp.teacher = maps[i]['teacher'];
    temp.lessonStartTimeString = maps[i]['lessonStartTime'];
    temp.creatingTime = maps[i]['creatingTime'];
    temp.justificationStateName = maps[i]['justificationStateName'];
    temp.justificationTypeName = maps[i]['justificationTypeName'];
    temp.osztalyCsoportUid = maps[i]['osztalyCsoportUid'];
    temp.justificationState = maps[i]['justificationState'];
    temp.justificationType = maps[i]['justificationType'];
    temp.osztalyCsoportUid = maps[i]['osztalyCsoportUid'];
    temp.numberOfLessons = maps[i]['numberOfLessons'];
    return temp;
  });
  if (tempList.length == 0) return [];
  tempList.sort(
    (a, b) => (b.lessonStartTimeString + " " + b.numberOfLessons.toString())
        .compareTo(
      a.lessonStartTimeString + " " + a.numberOfLessons.toString(),
    ),
  );
  int index = 0;*/
  List<List<Absence>> outputList = [[]];
  /*DateTime dateBefore = DateTime.parse(tempList[0].lessonStartTimeString);
  for (var n in tempList) {
    if (!DateTime.parse(n.lessonStartTimeString).isSameDay(dateBefore)) {
      index++;
      outputList.add([]);
      dateBefore = DateTime.parse(n.lessonStartTimeString);
    }
    outputList[index].add(n);
  }*/
  return outputList;
}
