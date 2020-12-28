import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/classGroup.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/parsing/parseAbsences.dart';
import 'package:sqflite/sqflite.dart';

Future<List<List<Absence>>> getAllAbsencesMatrix() async {
  FirebaseCrashlytics.instance.log("getAllAbsencesMatrix");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Absences GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Absence> tempList = List.generate(maps.length, (i) {
    Absence temp = new Absence();
    temp.databaseId = maps[i]['databaseId'];
    temp.justificationState = maps[i]['justificationState'];
    temp.justificationType = maps[i]['justificationType'] == null
        ? null
        : Description.fromJson(json.decode(maps[i]['justificationType']));
    temp.delayInMinutes = maps[i]['delayInMinutes'];
    temp.uid = maps[i]['uid'];
    temp.mode = maps[i]['mode'] == null
        ? null
        : Description.fromJson(json.decode(maps[i]['mode']));
    temp.date = maps[i]['date'] == null
        ? null
        : DateTime.parse(maps[i]['date']).toLocal();
    temp.lesson = maps[i]['lesson'] == null
        ? null
        : AbsenceLesson.fromJson(json.decode(maps[i]['lesson']));
    temp.teacher = maps[i]['teacher'];
    temp.subject = maps[i]['subject'] == null
        ? null
        : Subject.fromJson(json.decode(maps[i]['subject']));
    temp.type = maps[i]['type'] == null
        ? null
        : Description.fromJson(json.decode(maps[i]['type']));
    temp.group = maps[i]['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(maps[i]['group']));
    temp.createDate = maps[i]['createDate'] == null
        ? null
        : DateTime.parse(maps[i]['createDate']).toLocal();
    temp.userId = maps[i]['userId'];

    return temp;
  });
  return makeAbsencesMatrix(tempList);
}

Future<void> batchInsertAbsences(List<Absence> absenceList) async {
  FirebaseCrashlytics.instance.log("batchInsertAbsences");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  List<List<Absence>> tempAbsencesMatrix = await getAllAbsencesMatrix();
  List<dynamic> allAbsences =
      List.from(tempAbsencesMatrix).expand((i) => i).toList();
  for (var absence in absenceList) {
    var matchedAbsences = allAbsences.where((element) {
      return (element.uid == absence.uid && element.userId == absence.userId);
    });
    if (matchedAbsences.length == 0) {
      inserted = true;
      batch.insert(
        'Absences',
        absence.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedAbsences) {
        //!Update didn't work so we delete and create a new one
        if (n.justificationState != absence.justificationState ||
            n.justificationType.toJson() !=
                absence.justificationType.toJson() ||
            n.delayInMinutes != absence.delayInMinutes) {
          inserted = true;
          batch.delete(
            "Absences",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Absences',
            absence.toMap(),
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
