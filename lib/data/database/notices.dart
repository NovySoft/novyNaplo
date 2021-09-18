import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:flutter/foundation.dart';

Future<List<Notice>> getAllNotices({
  bool userSpecific = false,
}) async {
  FirebaseCrashlytics.instance.log("getAllNotices");
  // Get a reference to the database.
  List<Map<String, dynamic>> maps;
  if (userSpecific) {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Notices WHERE userId = ? GROUP BY uid, userId ORDER BY databaseId',
      [globals.currentUser.userId],
    );
  } else {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Notices GROUP BY uid, userId ORDER BY databaseId',
    );
  }

  List<Notice> tempList = List.generate(maps.length, (i) {
    Notice temp = new Notice.fromSqlite(maps[i]);
    return temp;
  });

  tempList.sort((a, b) => b.date.compareTo(a.date));

  return tempList;
}

Future<void> batchInsertNotices(
  List<Notice> noticeList,
  Student userDetails,
) async {
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
      NotificationDispatcher.toBeDispatchedNotifications.notices.add(
        NotificationData(
          title:
              '${(globals.allUsers.length == 1 ? getTranslatedString("newNotice") : getTranslatedString(
                      "XsNewNotice",
                      replaceVariables: [
                        userDetails.nickname ?? userDetails.name
                      ],
                    ))}: ' +
                  capitalize(notice.title),
          subtitle: notice.teacher,
          userId: notice.userId,
          uid: notice.uid,
          payload: "notice ${notice.userId} ${notice.uid}",
          isEdited: false,
        ),
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
          NotificationDispatcher.toBeDispatchedNotifications.notices.add(
            NotificationData(
              title:
                  '${(globals.allUsers.length == 1 ? getTranslatedString("noticeModified") : getTranslatedString(
                          "XsNoticeModified",
                          replaceVariables: [
                            userDetails.nickname ?? userDetails.name
                          ],
                        ))}: ' +
                      capitalize(notice.title),
              subtitle: notice.teacher,
              userId: notice.userId,
              uid: notice.uid,
              payload: "notice ${notice.userId} ${notice.uid}",
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
  handleNoticeDeletion(
    remoteNotices: noticeList,
    localNotices: allNotices,
    userDetails: userDetails,
  );
}

Future<void> handleNoticeDeletion({
  @required List<Notice> remoteNotices,
  @required List<Notice> localNotices,
  @required Student userDetails,
}) async {
  if (remoteNotices == null) return;
  List<Notice> filteredLocalNotices = List.from(localNotices)
      .where((element) => element.userId == userDetails.userId)
      .toList()
      .cast<Notice>();
  // Get a reference to the database.
  final Batch batch = globals.db.batch();
  bool deleted = false;
  for (var local in filteredLocalNotices) {
    if (remoteNotices.indexWhere(
          (element) =>
              element.uid == local.uid && element.userId == local.userId,
        ) ==
        -1) {
      deleted = true;
      print("Local notice doesn't exist in remote $local ${local.databaseId}");
      FirebaseAnalytics().logEvent(
        name: "RemoteDeletion",
        parameters: {
          "dataType": "notices",
        },
      );
      batch.delete(
        "Notices",
        where: "databaseId = ?",
        whereArgs: [local.databaseId],
      );
    }
  }
  if (deleted) {
    await batch.commit();
  }
}
