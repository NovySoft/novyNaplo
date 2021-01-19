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
  List<dynamic> allAbsences =
      List.from(tempAbsencesMatrix).expand((i) => i).toList();
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
}
