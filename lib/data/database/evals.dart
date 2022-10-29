import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:flutter/foundation.dart';

Future<List<Evals>> getAllEvals({
  bool userSpecific = false,
}) async {
  FirebaseCrashlytics.instance.log("getAllEvals");

  List<Map<String, dynamic>> maps;
  if (userSpecific) {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Evals WHERE userId = ? GROUP BY uid, userId ORDER BY databaseId',
      [globals.currentUser.userId],
    );
  } else {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Evals GROUP BY uid, userId ORDER BY databaseId',
    );
  }

  List<Evals> tempList = List.generate(maps.length, (i) {
    Evals temp = new Evals.fromSqlite(maps[i]);
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

Future<double> getEvalAssocedClassAv(int userId, String uid) async {
  FirebaseCrashlytics.instance.log("getEvalAssocedClassAv");
  var result = await globals.db.rawQuery(
    'SELECT classAv FROM Evals WHERE userId = ? AND uid = ?',
    [
      userId,
      uid,
    ],
  );
  if (result.length > 0) {
    return result[0]['classAv'];
  } else {
    return null;
  }
}

// A function that inserts multiple evals into the database
Future<void> batchInsertEvals(List<Evals> evalList, Student userDetails) async {
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
      if (userDetails.fetched)
        NotificationDispatcher.toBeDispatchedNotifications.marks.add(
          NotificationData(
            title:
                '${(globals.allUsers.length == 1 ? getTranslatedString("newMark") : getTranslatedString(
                        "XsNewMark",
                        replaceVariables: [
                          userDetails.nickname ?? userDetails.name
                        ],
                      ))}: ' +
                    capitalize(eval.subject.name) +
                    " " +
                    eval.textValue,
            subtitle: '${getTranslatedString("theme")}: ' + eval.theme,
            userId: eval.userId,
            uid: eval.uid,
            additionalKey: eval.subject.name,
            payload: "marks ${eval.userId} ${eval.uid}",
            isEdited: false,
          ),
        );
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
          // Keep old classAv
          eval.classAv = n.classAv;
          batch.insert(
            'Evals',
            eval.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print("Mark modified $eval");
          if (userDetails.fetched)
            NotificationDispatcher.toBeDispatchedNotifications.marks.add(
              NotificationData(
                title:
                    '${(globals.allUsers.length == 1 ? getTranslatedString("markModified") : getTranslatedString(
                            "XsMarkModified",
                            replaceVariables: [
                              userDetails.nickname ?? userDetails.name
                            ],
                          ))}: ' +
                        capitalize(eval.subject.name) +
                        " " +
                        eval.textValue,
                subtitle: '${getTranslatedString("theme")}: ' + eval.theme,
                userId: eval.userId,
                uid: eval.uid,
                additionalKey: eval.subject.name,
                payload: "marks ${eval.userId} ${eval.uid}",
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
  handleEvalsDeletion(
    remoteEvals: evalList,
    localEvals: allEvals,
    userDetails: userDetails,
  );
}

Future<void> handleEvalsDeletion({
  @required List<Evals> remoteEvals,
  @required List<Evals> localEvals,
  @required Student userDetails,
}) async {
  if (remoteEvals == null) return;
  List<Evals> filteredLocalEvals = List.from(localEvals)
      .where((element) => element.userId == userDetails.userId)
      .toList()
      .cast<Evals>();
  // Get a reference to the database.
  final Batch batch = globals.db.batch();
  bool deleted = false;
  for (var local in filteredLocalEvals) {
    if (remoteEvals.indexWhere(
          (element) =>
              element.uid == local.uid && element.userId == local.userId,
        ) ==
        -1) {
      deleted = true;
      print("Local eval doesn't exist in remote $local ${local.databaseId}");
      FirebaseAnalytics.instance.logEvent(
        name: "RemoteDeletion",
        parameters: {
          "dataType": "evals",
        },
      );
      batch.delete(
        "Evals",
        where: "databaseId = ?",
        whereArgs: [local.databaseId],
      );
    }
  }
  if (deleted) {
    await batch.commit();
  }
}
