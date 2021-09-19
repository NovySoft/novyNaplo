import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/parsing/parseAbsences.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';

Future<List<List<Absence>>> getAllAbsencesMatrix({
  bool userSpecific = false,
}) async {
  FirebaseCrashlytics.instance.log("getAllAbsencesMatrix");

  List<Map<String, dynamic>> maps;
  if (userSpecific) {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Absences WHERE userId = ? GROUP BY uid, userId ORDER BY databaseId',
      [globals.currentUser.userId],
    );
  } else {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Absences GROUP BY uid, userId ORDER BY databaseId',
    );
  }

  List<Absence> tempList = List.generate(maps.length, (i) {
    Absence temp = new Absence.fromSqlite(maps[i]);
    return temp;
  });

  return makeAbsencesMatrix(tempList);
}

Future<void> batchInsertAbsences(
  List<Absence> absenceList,
  Student userDetails,
) async {
  FirebaseCrashlytics.instance.log("batchInsertAbsences");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  List<List<Absence>> tempAbsencesMatrix = await getAllAbsencesMatrix();
  List<Absence> allAbsences =
      List.from(tempAbsencesMatrix).expand((i) => i).toList().cast<Absence>();
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
      NotificationDispatcher.toBeDispatchedNotifications.absences.add(
        NotificationData(
          title: '${absence.delayInMinutes == 0 || absence.delayInMinutes == null ? (globals.allUsers.length == 1 ? getTranslatedString("newAbsence") : getTranslatedString(
              "XsNewAbsence",
              replaceVariables: [userDetails.nickname ?? userDetails.name],
            )) : (globals.allUsers.length == 1 ? getTranslatedString("newDelay") : getTranslatedString(
              "XsNewDelay",
              replaceVariables: [userDetails.nickname ?? userDetails.name],
            ))}: ',
          subtitle:
              "${absence.date.toDayOnlyString()} (${absence.lesson.lessonNumber.intToTHEnding()} ${getTranslatedString("lesson")})",
          userId: absence.userId,
          uid: absence.uid,
          payload: "absence ${absence.userId} ${absence.uid}",
          isEdited: false,
        ),
      );
    } else {
      for (var n in matchedAbsences) {
        //!Update didn't work so we delete and create a new one
        if (n.justificationState != absence.justificationState ||
            (n.justificationType == null ? "" : n.justificationType.toJson()) !=
                (absence.justificationType == null
                    ? ""
                    : absence.justificationType.toJson()) ||
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
          NotificationDispatcher.toBeDispatchedNotifications.absences.add(
            NotificationData(
              title: '${absence.delayInMinutes == 0 || absence.delayInMinutes == null ? (globals.allUsers.length == 1 ? getTranslatedString("editedAbsence") : getTranslatedString(
                  "XsEditedAbsence",
                  replaceVariables: [userDetails.nickname ?? userDetails.name],
                )) : (globals.allUsers.length == 1 ? getTranslatedString("editedDelay") : getTranslatedString(
                  "XsEditedDelay",
                  replaceVariables: [userDetails.nickname ?? userDetails.name],
                ))}:',
              subtitle:
                  "${getTranslatedString(absence.justificationState)}: ${absence.subject} - ${absence.teacher}",
              userId: absence.userId,
              uid: absence.uid,
              payload: "absence ${absence.userId} ${absence.uid}",
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
  handleAbsenceDeletion(
    remoteAbsences: absenceList,
    localAbsences: allAbsences,
    userDetails: userDetails,
  );
}

Future<void> handleAbsenceDeletion({
  @required List<Absence> remoteAbsences,
  @required List<Absence> localAbsences,
  @required Student userDetails,
}) async {
  if (remoteAbsences == null) return;
  List<Absence> filteredLocalAbsences = List.from(localAbsences)
      .where((element) => element.userId == userDetails.userId)
      .toList()
      .cast<Absence>();
  // Get a reference to the database.
  final Batch batch = globals.db.batch();
  bool deleted = false;
  for (var local in filteredLocalAbsences) {
    if (remoteAbsences.indexWhere(
          (element) =>
              element.uid == local.uid && element.userId == local.userId,
        ) ==
        -1) {
      deleted = true;
      print("Local absence doesn't exist in remote $local ${local.databaseId}");
      batch.delete(
        "Absences",
        where: "databaseId = ?",
        whereArgs: [local.databaseId],
      );
      FirebaseAnalytics().logEvent(
        name: "RemoteDeletion",
        parameters: {
          "dataType": "absence",
        },
      );
    }
  }
  if (deleted) {
    await batch.commit();
  }
}
