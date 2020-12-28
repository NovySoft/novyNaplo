import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/classGroup.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:sqflite/sqflite.dart';

import 'deleteSql.dart';

Future<List<Homework>> getAllHomework({bool ignoreDue = true}) async {
  FirebaseCrashlytics.instance.log("getAllHw");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Homework GROUP BY userId, uid ORDER BY databaseId',
  );

  List<Homework> tempList = List.generate(maps.length, (i) {
    Homework temp = new Homework();
    temp.attachments = maps[i]['attachments'] == null
        ? null
        : Attachment.fromJsonList(maps[i]['attachments']);
    temp.giveUpDate = maps[i]['date'] == null
        ? null
        : DateTime.parse(maps[i]['date']).toLocal();
    temp.dueDate = maps[i]['dueDate'] == null
        ? null
        : DateTime.parse(maps[i]['dueDate']).toLocal();
    temp.createDate = maps[i]['createDate'] == null
        ? null
        : DateTime.parse(maps[i]['createDate']).toLocal();
    temp.isTeacherHW = maps[i]['isTeacherHW'] == 1 ? true : false;
    temp.isStudentHomeworkEnabled =
        maps[i]['isStudentHomeworkEnabled'] == 1 ? true : false;
    temp.isSolved = maps[i]['isSolved'] == 1 ? true : false;
    temp.teacher = maps[i]['teacher'];
    temp.content = maps[i]['content'];
    temp.subject = maps[i]['subject'] == null
        ? null
        : Subject.fromJson(json.decode(maps[i]['subject']));
    temp.group = maps[i]['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(maps[i]['group']));
    temp.uid = maps[i]['uid'];
    temp.userId = maps[i]['userId'];
    temp.databaseId = maps[i]['databaseId'];
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
  tempList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return tempList;
}

Future<void> batchInsertHomework(List<Homework> hwList) async {
  FirebaseCrashlytics.instance.log("batchInsertHomework");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  List<Homework> allHw = await getAllHomework();
  for (var hw in hwList) {
    var matchedHw = allHw.where((element) {
      return (element.uid == hw.uid && element.subject.name == hw.subject.name);
    });
    if (matchedHw.length == 0) {
      inserted = true;
      batch.insert(
        'Homework',
        hw.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedHw) {
        //!Update didn't work so we delete and create a new one
        if (n.content != hw.content ||
            n.dueDate.toUtc().toIso8601String() !=
                hw.dueDate.toUtc().toIso8601String() ||
            n.giveUpDate.toUtc().toIso8601String() !=
                hw.giveUpDate.toUtc().toIso8601String()) {
          inserted = true;
          batch.delete(
            "Homework",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Homework',
            hw.toMap(),
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

Future<void> insertHomework(Homework hw, {bool edited}) async {
  FirebaseCrashlytics.instance.log("insertSingleHw");

  List<Homework> allHw = await getAllHomework();
  var matchedHw = allHw.where((element) {
    return (element.uid == hw.uid && element.subject.name == hw.subject.name);
  });

  DateTime afterDue = hw.dueDate;
  if (globals.howLongKeepDataForHw != -1) {
    afterDue =
        afterDue.add(Duration(days: globals.howLongKeepDataForHw.toInt()));
  }

  if (matchedHw.length == 0) {
    if (afterDue.isBefore(DateTime.now())) {
      print("OUT OF RANGE");
      if (hw.databaseId != null && globals.howLongKeepDataForHw != -1) {
        print("Deleted ${hw.databaseId}");
        await deleteFromDb(hw.databaseId, "Homework");
      }
      return;
    }
    await globals.db.insert(
      'Homework',
      hw.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    for (var n in matchedHw) {
      if (afterDue.compareTo(DateTime.now()) < 0) {
        print("OUT OF RANGE");
        if (n.databaseId != null && globals.howLongKeepDataForHw != -1) {
          print("Deleted ${n.databaseId}");
          await deleteFromDb(n.databaseId, "Homework");
        }
        return;
      }
      //!Update didn't work so we delete and create a new one
      if (n.content != hw.content ||
          n.dueDate.toUtc().toIso8601String() !=
              hw.dueDate.toUtc().toIso8601String() ||
          n.giveUpDate.toUtc().toIso8601String() !=
              hw.giveUpDate.toUtc().toIso8601String()) {
        await deleteFromDb(n.databaseId, "Homework");
        insertHomework(hw, edited: true);
      }
    }
  }
}
