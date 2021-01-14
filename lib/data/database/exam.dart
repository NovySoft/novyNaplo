import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;

Future<List<Exam>> getAllExams() async {
  FirebaseCrashlytics.instance.log("getAllExams");
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Exams GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Exam> tempList = List.generate(maps.length, (i) {
    Exam temp = new Exam.fromSqlite(maps[i]);
    return temp;
  });

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
