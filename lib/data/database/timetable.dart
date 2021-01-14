import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/classGroup.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;

Future<List<Lesson>> getAllTimetable() async {
  FirebaseCrashlytics.instance.log("getAllTimetable");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Timetable GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Lesson> outputTempList = List.generate(maps.length, (i) {
    Lesson temp = new Lesson.fromSqlite(maps[i]);
    return temp;
  });
  deleteOldLessonsFromList(outputTempList);
  return outputTempList;
}

void deleteOldLessonsFromList(List<Lesson> input) async {
  Batch batch = globals.db.batch();
  bool deleted = false;
  for (var item in input) {
    DateTime date = item.endDate;
    if (item.databaseId != null) {
      //!Delete all lessons after a month of their ending
      date = date.add(Duration(days: 30));
      if (date.compareTo(DateTime.now()) < 0) {
        deleted = true;
        batch.delete(
          "Timetable",
          where: "databaseId = ?",
          whereArgs: [item.databaseId],
        );
      }
    }
  }
  if (deleted) {
    batch.commit();
  }
}

Future<void> batchInsertLessons(List<Lesson> lessonList,
    {bool lookAtDate = false}) async {
  FirebaseCrashlytics.instance.log("batchInsertLessons");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  //Get all evals, and see whether we should be just replacing
  List<Lesson> allTimetable = await getAllTimetable();
  for (var lesson in lessonList) {
    if (lookAtDate) {
      if (lesson.endDate
              .add(
                Duration(days: 30),
              )
              .compareTo(
                DateTime.now(),
              ) <
          0) {
        break;
      }
    }
    var matchedLessons = allTimetable.where(
      (element) {
        return (element.uid == lesson.uid && element.userId == lesson.userId);
      },
    );

    if (matchedLessons.length == 0) {
      inserted = true;
      batch.insert(
        'Timetable',
        lesson.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedLessons) {
        //!Update didn't work so we delete and create a new one
        if ((n.theme != lesson.theme ||
                n.teacher != lesson.teacher ||
                n.deputyTeacher != lesson.deputyTeacher ||
                n.name != lesson.name ||
                n.classroom != lesson.classroom ||
                n.teacherHwUid != lesson.teacherHwUid ||
                json.encode(n.examUidList) != json.encode(n.examUidList) ||
                n.startDate.toUtc().toIso8601String() !=
                    lesson.startDate.toUtc().toIso8601String() ||
                n.endDate.toUtc().toIso8601String() !=
                    lesson.endDate.toUtc().toIso8601String()) &&
            n.uid == lesson.uid) {
          inserted = true;
          batch.delete(
            "Timetable",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Timetable',
            lesson.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }
}
