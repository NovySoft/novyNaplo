import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';

Future<List<Average>> getAllAverages() async {
  FirebaseCrashlytics.instance.log("getAllAverages");
  // Get a reference to the database.
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Average GROUP BY subject, userId ORDER BY databaseId',
  );

  return List.generate(maps.length, (i) {
    Average temp = new Average();
    temp.databaseId = maps[i]['databaseId'];
    temp.subjectUid = maps[i]['subject'];
    temp.value = maps[i]['ownValue'];
    temp.userId = maps[i]['userId'];
    temp.classAverage = maps[i]['classValue'];
    return temp;
  });
}

Future<void> batchInsertAverages(
  List<Average> averageList,
  Student userDetails,
) async {
  FirebaseCrashlytics.instance.log("batchInsertAvarage");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  List<Average> allAv = await getAllAverages();
  for (var average in averageList) {
    if (average.userId == null) continue;
    var matchedAv = allAv.where((element) {
      return (element.subjectUid == average.subjectUid &&
          element.userId == average.userId);
    });
    if (matchedAv.length == 0) {
      inserted = true;
      batch.insert(
        'Average',
        average.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedAv) {
        //!Update didn't work so we delete and create a new one
        if (n.value != average.value ||
            n.classAverage != average.classAverage) {
          inserted = true;
          batch.delete(
            "Average",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Average',
            average.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          String diff;
          if (average.value == null || n.value == null) {
            if (average.value != null && n.value == null) {
              diff = "+${average.value.toStringAsFixed(3)}";
            } else {
              diff = "null";
            }
          } else {
            double diffValue = average.value - n.value;
            diff = diffValue > 0
                ? ("+${diffValue.toStringAsFixed(3)}")
                : diffValue.toStringAsFixed(3);
          }
          if (userDetails.fetched)
            NotificationDispatcher.toBeDispatchedNotifications.averages.add(
              NotificationData(
                title:
                    '${(globals.allUsers.length == 1 ? getTranslatedString("avChanged") : getTranslatedString(
                            "XsAvChanged",
                            replaceVariables: [
                              userDetails.nickname ?? userDetails.name
                            ],
                          ))}: ' +
                        capitalize(average.subjectName),
                subtitle: '${getTranslatedString("newAv")}: ' +
                    average.value.toStringAsFixed(5) +
                    " ($diff)",
                userId: average.userId,
                uid: average.subjectUid,
                payload: "average ${average.userId} ${average.subjectUid}",
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
