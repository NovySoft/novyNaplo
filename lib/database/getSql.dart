import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;

// A method that retrieves all the evals from the table.
Future<List<Evals>> getAllEvals() async {
  Crashlytics.instance.log("getAllEvals");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  // Query the table for all the evals.
  final List<Map<String, dynamic>> maps = await db.query('Evals');

  // Convert the List<Map<String, dynamic> into a List<Evals>.
  return List.generate(maps.length, (i) {
    Evals temp = new Evals();
    temp.id = maps[i]['id'];
    temp.formName = maps[i]['formName'];
    temp.form = maps[i]['form'];
    temp.value = maps[i]['value'];
    temp.numberValue = maps[i]['numberValue'];
    temp.teacher = maps[i]['teacher'];
    temp.type = maps[i]['type'];
    temp.subject = maps[i]['subject'];
    temp.theme = maps[i]['theme'];
    temp.mode = maps[i]['mode'];
    temp.weight = maps[i]['weight'];
    temp.databaseId = maps[i]['databaseId'];
    temp.dateString = maps[i]['dateString'];
    temp.createDateString = maps[i]['createDateString'];
    temp.date = DateTime.parse(temp.dateString);
    temp.createDate = DateTime.parse(temp.createDateString);
    return temp;
  });
}

Future<List<Notices>> getAllNotices() async {
  Crashlytics.instance.log("getAllNotices");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.query('Notices');

  return List.generate(maps.length, (i) {
    Notices temp = new Notices();
    temp.databaseId = maps[i]['databaseId'];
    temp.id = maps[i]['id'];
    temp.title = maps[i]['title'];
    temp.content = maps[i]['content'];
    temp.teacher = maps[i]['teacher'];
    temp.dateString = maps[i]['dateString'];
    temp.subject = maps[i]['subject'];
    temp.date = DateTime.parse(temp.dateString);
    return temp;
  });
}

Future<List<Avarage>> getAllAvarages() async {
  Crashlytics.instance.log("getAllAvarages");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.query('Avarage');

  return List.generate(maps.length, (i) {
    Avarage temp = new Avarage();
    temp.databaseId = maps[i]['databaseId'];
    temp.subject = maps[i]['subject'];
    temp.ownValue = maps[i]['ownValue'];
    temp.classValue = maps[i]['classValue'];
    temp.diff = maps[i]['diff'];
    return temp;
  });
}

Future<List<Homework>> getAllHomework({bool ignoreDue = true}) async {
  Crashlytics.instance.log("getAllHw");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.query('Homework');

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
  return tempList;
}

Future<List<Lesson>> getAllTimetable() async {
  Crashlytics.instance.log("getAllTimetable");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.query('Timetable');

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
    if (timetablePage.fetchedDayList
            .where((element) => element.day == n.date.day)
            .length ==
        0) {
      timetablePage.fetchedDayList.add(n.date);
    }
    if (n.teacherHomeworkId != null) {
      n.homework = await getHomeworkById(n.teacherHomeworkId);
    } else if (n.homeWorkId != null) {
      n.homework = await getHomeworkById(n.homeWorkId);
    }
  }
  return outputTempList;
}

Future<Homework> getHomeworkById(int id) async {
  final Database db = await mainSql.database;
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
  return output;
}

Future<List<Exam>> getAllExams() async {
  Crashlytics.instance.log("getAllExams");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.query('Exams');

  return List.generate(maps.length, (i) {
    Exam temp = new Exam();
    temp.nameOfExam = maps[i]['nameOfExam'];
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
    return temp;
  });
}

Future<List<Event>> getAllEvents() async {
  Crashlytics.instance.log("getAllEvents");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  final List<Map<String, dynamic>> maps = await db.query('Events');

  return List.generate(maps.length, (i) {
    Event temp = new Event();
    temp.databaseId = maps[i]['databaseId'];
    temp.id = maps[i]['id'];
    temp.dateString = maps[i]['dateString'];
    temp.endDateString = maps[i]['endDateString'];
    temp.date = DateTime.parse(temp.dateString);
    temp.endDate = DateTime.parse(temp.endDateString);
    temp.title = maps[i]['title'];
    temp.content = maps[i]['content'];
    return temp;
  });
}
