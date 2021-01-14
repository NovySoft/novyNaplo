import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/classGroup.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;

Future<List<Notice>> getAllNotices() async {
  FirebaseCrashlytics.instance.log("getAllNotices");
  // Get a reference to the database.

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Notices GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Notice> tempList = List.generate(maps.length, (i) {
    Notice temp = new Notice.fromSqlite(maps[i]);
    return temp;
  });

  return tempList;
}

Future<void> batchInsertNotices(List<Notice> noticeList) async {
  FirebaseCrashlytics.instance.log("batchInsertNotices");
  bool inserted = false;
  // Get a reference to the database.
  final Batch batch = globals.db.batch();

  List<Notice> allNotices = await getAllNotices();

  for (var notice in noticeList) {
    var matchedNotices = allNotices.where((element) {
      return (element.uid == notice.uid && element.userId == notice.userId);
    });
    if (matchedNotices.length == 0) {
      inserted = true;
      batch.insert(
        'Notices',
        notice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedNotices) {
        //!Update didn't work so we delete and create a new one
        if ((n.title != notice.title || n.content != notice.content) &&
            n.uid == notice.uid) {
          inserted = true;
          batch.delete(
            "Notices",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Notices',
            notice.toMap(),
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
