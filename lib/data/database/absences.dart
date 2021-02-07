import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/parsing/parseAbsences.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';

Future<List<List<Absence>>> getAllAbsencesMatrix() async {
  FirebaseCrashlytics.instance.log("getAllAbsencesMatrix");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Absences GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Absence> tempList = List.generate(maps.length, (i) {
    Absence temp = new Absence.fromSqlite(maps[i]);
    return temp;
  });

  return makeAbsencesMatrix(tempList);
}

Future<void> batchInsertAbsences(List<Absence> absenceList) async {
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
          title:
              '${absence.delayInMinutes == 0 || absence.delayInMinutes == null ? getTranslatedString("newAbsence") : getTranslatedString("newDelay")}: ',
          subtitle:
              "${absence.date.toDayOnlyString()} (${absence.lesson.lessonNumber} ${getTranslatedString("lesson")})",
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
            n.justificationType.toJson() !=
                absence.justificationType.toJson() ||
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
              title:
                  '${absence.delayInMinutes == 0 || absence.delayInMinutes == null ? getTranslatedString("editedAbsence") : getTranslatedString("editedDelay")}:',
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
  handleEvalsDeletion(
    remoteAbsences: absenceList,
    localAbsences: allAbsences,
  );
}

Future<void> handleEvalsDeletion({
  List<Absence> remoteAbsences,
  List<Absence> localAbsences,
}) async {
  if (remoteAbsences == null) return;
  if (remoteAbsences.length == 0) return;
  // Get a reference to the database.
  final Batch batch = globals.db.batch();
  bool deleted = false;
  for (var local in localAbsences) {
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
