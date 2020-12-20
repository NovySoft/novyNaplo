import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/classGroup.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/helpers/data/decryptionHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;

Future<List<Notice>> getAllNotices() async {
  FirebaseCrashlytics.instance.log("getAllNotices");
  // Get a reference to the database.

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Notices GROUP BY uid, userId ORDER BY databaseId',
  );

  return List.generate(maps.length, (i) {
    Notice temp = new Notice();
    temp.title = maps[i]['title'];
    temp.date = DateTime.parse(maps[i]['date']).toLocal();
    temp.createDate = DateTime.parse(maps[i]['createDate']).toLocal();
    temp.teacher = maps[i]['teacher'];
    temp.seenDate = DateTime.parse(maps[i]['seenDate']).toLocal();
    temp.group = ClassGroup.fromJson(json.decode(maps[i]['group']));
    temp.content = maps[i]['content'];
    temp.subject = maps[i]['subject'] == null
        ? null
        : Subject.fromJson(json.decode(maps[i]['subject']));
    temp.type = Description.fromJson(json.decode(maps[i]['type']));
    temp.uid = maps[i]['uid'];
    temp.databaseId = maps[i]['databaseId'];
    temp.userId = maps[i]['userId'];
    return temp;
  });
}

Future<void> batchInsertNotices(List<Notice> noticeList) async {
  FirebaseCrashlytics.instance.log("batchInsertNotices");
  bool inserted = false;
  // Get a reference to the database.
  final Batch batch = globals.db.batch();

  List<Notice> allNotices = await getAllNotices();

  for (var notice in noticeList) {
    var matchedNotices = allNotices.where((element) {
      return (element.title == notice.title || element.uid == notice.uid);
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
