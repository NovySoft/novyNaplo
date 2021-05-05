import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/subjectNicknames.dart';
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

Future<void> updateSubject({
  @required String uid,
  @required int dbId,
  @required String subject,
  @required String dbName,
}) async {
  if (uid == null || dbId == null || subject == null || dbName == null) return;
  print(
      "UPDATE $dbName SET Subject = $subject WHERE uid = $uid OR databaseId = $dbId");
  await globals.db.rawUpdate(
    "UPDATE $dbName SET Subject = ? WHERE uid = ? OR databaseId = ?",
    [
      subject,
      uid,
      dbId,
    ],
  );
}

Future<List<List<SubjectNicknames>>> getSubjNickMatrix(bool isTimetable) async {
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    isTimetable
        ? 'SELECT * FROM Subjects WHERE teacher IS NOT NULL'
        : 'SELECT * FROM Subjects WHERE teacher IS NULL',
  );

  List<List<SubjectNicknames>> output = [[]];
  List<SubjectNicknames> temp = [];
  for (var n in maps) {
    temp.add(
      SubjectNicknames(
        uid: n["uid"],
        fullName: n["fullname"],
        nickName: n["nickname"],
        category: json.decode(n["category"])["Nev"],
        teacher: n["teacher"],
      ),
    );
  }
  temp.sort((a, b) => a.category.compareTo(b.category));
  //Create matrix
  int index = 0;
  String categoryBefore = temp[0].category;
  for (var n in temp) {
    if (n.category != categoryBefore) {
      index++;
      output.last.sort((a, b) => a.fullName.compareTo(b.fullName));
      output.add([]);
      categoryBefore = n.category;
    }
    output[index].add(n);
  }

  return output;
}

Future<void> updateNickname(Subject subject) async {
  print(
      "UPDATE Subjects SET nickname = ${subject.name} WHERE uid = ${subject.uid}");
  await globals.db.rawUpdate(
    "UPDATE Subjects SET nickname = ? WHERE uid = ?",
    [
      subject.name,
      subject.uid,
    ],
  );
}
