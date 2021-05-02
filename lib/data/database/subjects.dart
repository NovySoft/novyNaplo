import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:sqflite/sqflite.dart';

Future<void> insertSubject(Subject input, String teacher) async {
  FirebaseCrashlytics.instance.log("insertSubject");

  await globals.db.insert(
    'Subjects',
    {
      "uid": input.uid,
      "category": input.category.toJson(),
      "nickname": input.name,
      "fullname": input.fullName,
      "teacher": teacher,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<Map<String, Subject>> getSubjectMap() async {
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Subjects',
  );

  Map<String, Subject> output = new Map<String, Subject>();
  for (var i = 0; i < maps.length; i++) {
    output[maps[i]["uid"]] = Subject.fromSqlite(maps[i]);
  }

  return output;
}
