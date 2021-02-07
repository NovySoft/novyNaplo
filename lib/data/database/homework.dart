import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'deleteSql.dart';
import 'package:flutter/foundation.dart';

Future<List<Homework>> getAllHomework({bool ignoreDue = true}) async {
  FirebaseCrashlytics.instance.log("getAllHw");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Homework GROUP BY userId, uid ORDER BY databaseId',
  );

  List<Homework> tempList = List.generate(maps.length, (i) {
    Homework temp = new Homework.fromSqlite(maps[i]);
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
  deleteOldHomework(tempList);
  return tempList;
}

void deleteOldHomework(List<Homework> input) async {
  //!It is implemented as a safety measure, no matter what the user set for due date keeping homeworks will be removed from the db if they're over due with 180days
  Batch batch = globals.db.batch();
  bool deleted = false;
  for (var item in input) {
    DateTime afterDue = item.dueDate;
    if (item.databaseId != null) {
      if (globals.howLongKeepDataForHw == -1) {
        afterDue = afterDue.add(Duration(days: 180));
      } else {
        //?If someone is not really keen on showing the homework after 14 days, we delete it after 30 days
        afterDue = afterDue.add(Duration(days: 30));
      }
      if (afterDue.compareTo(DateTime.now()) < 0) {
        deleted = true;
        batch.delete(
          "Homework",
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

Future<void> batchInsertHomework(List<Homework> hwList) async {
  FirebaseCrashlytics.instance.log("batchInsertHomework");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  //We need everything that is in the db, so ignore due removing
  List<Homework> allHw = await getAllHomework(ignoreDue: true);
  for (var hw in hwList) {
    var matchedHw = allHw.where((element) {
      return (element.uid == hw.uid && element.userId == hw.userId);
    });
    if (matchedHw.length == 0) {
      inserted = true;
      batch.insert(
        'Homework',
        hw.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      NotificationDispatcher.toBeDispatchedNotifications.homeworks.add(
        NotificationData(
          title:
              '${getTranslatedString("newHw")}: ' + capitalize(hw.subject.name),
          subtitle:
              "${getTranslatedString("due")}: ${hw.dueDate.toDayOnlyString()}",
          userId: hw.userId,
          uid: hw.uid,
          payload: "hw ${hw.userId} ${hw.uid}",
          additionalKey: hw.subject.name,
          isEdited: false,
        ),
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
          NotificationDispatcher.toBeDispatchedNotifications.homeworks.add(
            NotificationData(
              title: '${getTranslatedString("hwModified")}: ' +
                  capitalize(hw.subject.name),
              subtitle:
                  "${getTranslatedString("due")}: ${hw.dueDate.toDayOnlyString()}",
              userId: hw.userId,
              uid: hw.uid,
              payload: "hw ${hw.userId} ${hw.uid}",
              additionalKey: hw.subject.name,
              isEdited: true,
            ),
          );
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }
  handleHomeworkDeletion(
    remoteHomework: hwList,
    localHomework: allHw,
  );
}

Future<void> insertHomework(Homework hw, {bool edited = false}) async {
  FirebaseCrashlytics.instance.log("insertSingleHw");

  //We need everything that is in the db, so ignore due removing
  List<Homework> allHw = await getAllHomework(ignoreDue: true);
  var matchedHw = allHw.where((element) {
    return (element.uid == hw.uid && element.userId == hw.userId);
  });

  DateTime afterDue = hw.dueDate;
  if (globals.howLongKeepDataForHw == -1) {
    afterDue = afterDue.add(Duration(days: 180));
  } else {
    //?If someone is not really keen on showing the homework after 14 days, we delete it after 30 days
    afterDue = afterDue.add(Duration(days: 30));
  }

  if (matchedHw.length == 0) {
    if (afterDue.isBefore(DateTime.now())) {
      if (hw.databaseId != null && globals.howLongKeepDataForHw != -1) {
        await deleteFromDbByID(hw.databaseId, "Homework");
      }
      return;
    }
    await globals.db.insert(
      'Homework',
      hw.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (edited) {
      NotificationDispatcher.toBeDispatchedNotifications.homeworks.add(
        NotificationData(
          title: '${getTranslatedString("hwModified")}: ' +
              capitalize(hw.subject.name),
          subtitle:
              "${getTranslatedString("due")}: ${hw.dueDate.toDayOnlyString()}",
          userId: hw.userId,
          uid: hw.uid,
          payload: "hw ${hw.userId} ${hw.uid}",
          additionalKey: hw.subject.name,
          isEdited: true,
        ),
      );
    } else {
      NotificationDispatcher.toBeDispatchedNotifications.homeworks.add(
        NotificationData(
          title:
              '${getTranslatedString("newHw")}: ' + capitalize(hw.subject.name),
          subtitle:
              "${getTranslatedString("due")}: ${hw.dueDate.toDayOnlyString()}",
          userId: hw.userId,
          uid: hw.uid,
          payload: "hw ${hw.userId} ${hw.uid}",
          additionalKey: hw.subject.name,
          isEdited: false,
        ),
      );
    }
  } else {
    for (var n in matchedHw) {
      if (afterDue.compareTo(DateTime.now()) < 0) {
        if (n.databaseId != null && globals.howLongKeepDataForHw != -1) {
          await deleteFromDbByID(n.databaseId, "Homework");
        }
        return;
      }
      //!Update didn't work so we delete and create a new one
      if (n.content != hw.content ||
          n.dueDate.toUtc().toIso8601String() !=
              hw.dueDate.toUtc().toIso8601String() ||
          n.giveUpDate.toUtc().toIso8601String() !=
              hw.giveUpDate.toUtc().toIso8601String()) {
        await deleteFromDbByID(n.databaseId, "Homework");
        insertHomework(hw, edited: true);
      }
    }
  }
}

Future<void> handleHomeworkDeletion({
  @required List<Homework> remoteHomework,
  @required List<Homework> localHomework,
}) async {
  // Get a reference to the database.
  final Batch batch = globals.db.batch();
  bool deleted = false;
  for (var local in localHomework) {
    if (remoteHomework.indexWhere(
          (element) =>
              element.uid == local.uid && element.userId == local.userId,
        ) ==
        -1) {
      deleted = true;
      print(
        "Local homework doesn't exist in remote $local ${local.databaseId}",
      );
      FirebaseAnalytics().logEvent(
        name: "RemoteDeletion",
        parameters: {
          "dataType": "homeworks",
        },
      );
      batch.delete(
        "Homework",
        where: "databaseId = ?",
        whereArgs: [local.databaseId],
      );
    }
  }
  if (deleted) {
    await batch.commit();
  }
}
