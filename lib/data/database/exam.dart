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

Future<List<Exam>> getAllExams() async {
  FirebaseCrashlytics.instance.log("getAllExams");
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Exams GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Exam> tempList = List.generate(maps.length, (i) {
    Exam temp = new Exam();
    temp.announcementDate = maps[i]['announcementDate'] == null
        ? null
        : DateTime.parse(maps[i]['announcementDate']).toLocal();
    temp.dateOfWriting = maps[i]['dateOfWriting'] == null
        ? null
        : DateTime.parse(maps[i]['dateOfWriting']).toLocal();
    temp.mode = maps[i]['mode'] == null
        ? null
        : Description.fromJson(json.decode(maps[i]['mode']));
    temp.lessonNumber = maps[i]['lessonNumber'];
    temp.teacher = maps[i]['teacher'];
    temp.subject = maps[i]['subject'] == null
        ? null
        : Subject.fromJson(json.decode(maps[i]['subject']));
    temp.theme = maps[i]['theme'];
    temp.group = maps[i]['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(maps[i]['group']));
    temp.databaseId = maps[i]['databaseId'];
    temp.userId = maps[i]['userId'];
    temp.uid = maps[i]['uid'];
    temp.icon = parseSubjectToIcon(subject: temp.subject.name);
    return temp;
  });
  /*tempList.removeWhere(
      (temp) => temp.dateWrite.add(Duration(days: 7)).isBefore(DateTime.now()));*/
  return tempList;
}

Future<void> batchInsertExams(List<Exam> examList) async {
  FirebaseCrashlytics.instance.log("batchInsertExams");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  List<Exam> allExam = await getAllExams();
  for (var exam in examList) {
    var matchedExams = allExam.where((element) {
      return (element.uid == exam.uid && element.userId == exam.userId);
    });
    if (matchedExams.length == 0) {
      inserted = true;
      batch.insert(
        'Exams',
        exam.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedExams) {
        //!Update didn't work so we delete and create a new one
        if (n.dateOfWriting.toUtc().toIso8601String() !=
                exam.dateOfWriting.toUtc().toIso8601String() ||
            n.dateOfWriting.toUtc().toIso8601String() !=
                exam.dateOfWriting.toUtc().toIso8601String() ||
            n.theme != exam.theme ||
            n.mode.name != exam.mode.name) {
          inserted = true;
          batch.delete(
            "Exams",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Exams',
            exam.toMap(),
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
