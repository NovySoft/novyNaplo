import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/classGroup.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;

Future<List<Evals>> getAllEvals() async {
  FirebaseCrashlytics.instance.log("getAllEvals");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Evals GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Evals> tempList = List.generate(maps.length, (i) {
    Evals temp = new Evals();
    temp.databaseId = maps[i]['databaseId'];
    temp.userId = maps[i]['userId'];
    temp.uid = maps[i]['uid'];
    temp.teacher = maps[i]['teacher'];
    temp.valueType = maps[i]['valueType'] == null
        ? null
        : Description.fromJson(json.decode(maps[i]['valueType']));
    temp.kindOf = maps[i]['kindOf'];
    temp.createDate = maps[i]['createDate'] == null
        ? null
        : DateTime.parse(maps[i]['createDate']).toLocal();
    temp.seenDate = maps[i]['seenDate'] == null
        ? null
        : DateTime.parse(maps[i]['seenDate']).toLocal();
    temp.mode = maps[i]['mode'] == null
        ? null
        : Description.fromJson(json.decode(maps[i]['mode']));
    temp.date = maps[i]['date'] == null
        ? null
        : DateTime.parse(maps[i]['date']).toLocal();
    temp.weight = maps[i]['weight'];
    temp.numberValue = maps[i]['numberValue'];
    temp.textValue = maps[i]['textValue'];
    temp.shortTextValue = maps[i]['shortTextValue'];
    temp.subject = maps[i]['subject'] == null
        ? null
        : Subject.fromJson(json.decode(maps[i]['subject']));
    temp.theme = maps[i]['theme'];
    temp.type = maps[i]['type'] == null
        ? null
        : Description.fromJson(json.decode(maps[i]['type']));
    temp.group = maps[i]['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(maps[i]['group']));
    temp.sortIndex = maps[i]['sortIndex'];
    temp.icon = temp.subject != null
        ? parseSubjectToIcon(subject: temp.subject.name)
        : Icons.create;
    return temp;
  });
  tempList.sort(
    (a, b) {
      if (a.date.isSameDay(b.date)) {
        return b.createDate.compareTo(a.createDate);
      } else {
        return b.date.compareTo(a.date);
      }
    },
  );
  return tempList;
}

// A function that inserts multiple evals into the database
Future<void> batchInsertEvals(List<Evals> evalList) async {
  FirebaseCrashlytics.instance.log("batchInsertEval");
  bool inserted = false;
  // Get a reference to the database.
  final Batch batch = globals.db.batch();

  //Get all evals, and see whether we should be just replacing
  List<Evals> allEvals = await getAllEvals();
  for (var eval in evalList) {
    var matchedEvals = allEvals.where(
      (element) {
        return (element.uid == eval.uid && element.userId == eval.userId);
      },
    );
    if (matchedEvals.length == 0) {
      inserted = true;
      batch.insert(
        'Evals',
        eval.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      //FIXME Notification dispatch
    } else {
      for (var n in matchedEvals) {
        //!Update didn't work so we delete and create a new one
        if ((n.numberValue != eval.numberValue ||
                n.theme != eval.theme ||
                n.date.toUtc().toIso8601String() !=
                    eval.date.toUtc().toIso8601String() ||
                n.weight != eval.weight) &&
            n.uid == eval.uid) {
          inserted = true;
          batch.delete(
            "Evals",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Evals',
            eval.toMap(),
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
