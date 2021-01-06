import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/global.dart' as globals;
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
    temp.subject = maps[i]['subject'];
    temp.value = maps[i]['ownValue'];
    temp.userId = maps[i]['userId'];
    return temp;
  });
}

Future<void> batchInsertAverages(List<Average> averageList) async {
  FirebaseCrashlytics.instance.log("batchInsertAvarage");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  List<Average> allAv = await getAllAverages();
  for (var average in averageList) {
    var matchedAv = allAv.where((element) {
      return (element.subject == average.subject &&
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
        if (n.value != average.value) {
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
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }
}
