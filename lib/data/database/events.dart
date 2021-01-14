import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:sqflite/sqflite.dart';

Future<List<Event>> getAllEvents() async {
  FirebaseCrashlytics.instance.log("getAllEvents");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Events GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Event> tempList = List.generate(maps.length, (i) {
    Event temp = new Event.fromSqlite(maps[i]);
    return temp;
  });
  tempList.sort((a, b) => b.endDate.compareTo(a.endDate));
  return tempList;
}

Future<void> batchInsertEvents(List<Event> eventList) async {
  FirebaseCrashlytics.instance.log("batchInsertEvents");
  bool inserted = false;
  final Batch batch = globals.db.batch();
  List<Event> allEvents = await getAllEvents();

  for (var event in eventList) {
    var matchedEvents = allEvents.where((element) {
      return (element.uid == event.uid && element.userId == event.userId);
    });
    if (matchedEvents.length == 0) {
      inserted = true;
      batch.insert(
        'Events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedEvents) {
        //!Update didn't work so we delete and create a new one
        if (n.startDate != event.startDate ||
            n.endDate != event.endDate ||
            n.content != event.content ||
            n.title != event.title) {
          inserted = true;
          batch.delete(
            "Events",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Events',
            event.toMap(),
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
