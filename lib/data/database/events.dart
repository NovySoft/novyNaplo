import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

Future<List<Event>> getAllEvents({
  bool userSpecific = false,
}) async {
  FirebaseCrashlytics.instance.log("getAllEvents");

  List<Map<String, dynamic>> maps;
  if (userSpecific) {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Events WHERE userId = ? GROUP BY uid, userId ORDER BY databaseId',
      [globals.currentUser.userId],
    );
  } else {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Events GROUP BY uid, userId ORDER BY databaseId',
    );
  }

  List<Event> tempList = List.generate(maps.length, (i) {
    Event temp = new Event.fromSqlite(maps[i]);
    return temp;
  });
  tempList.sort((a, b) => b.endDate.compareTo(a.endDate));
  return tempList;
}

Future<void> batchInsertEvents(
  List<Event> eventList,
  Student userDetails,
) async {
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
      NotificationDispatcher.toBeDispatchedNotifications.events.add(
        NotificationData(
          title: '${getTranslatedString("newEvent")}: ',
          subtitle: event.title,
          userId: event.userId,
          uid: event.uid,
          payload: "event ${event.userId} ${event.uid}",
          isEdited: false,
        ),
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
          NotificationDispatcher.toBeDispatchedNotifications.events.add(
            NotificationData(
              title: '${getTranslatedString("editedEvent")}: ',
              subtitle: event.title,
              userId: event.userId,
              uid: event.uid,
              payload: "event ${event.userId} ${event.uid}",
              isEdited: false,
            ),
          );
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }
  handleEventDeletion(
    remoteEvents: eventList,
    localEvents: allEvents,
    userDetails: userDetails,
  );
}

Future<void> handleEventDeletion({
  @required List<Event> remoteEvents,
  @required List<Event> localEvents,
  @required Student userDetails,
}) async {
  if (remoteEvents == null) return;
  List<Event> filteredLocalEvents = List.from(localEvents)
      .where((element) => element.userId == userDetails.userId)
      .toList()
      .cast<Event>();
  // Get a reference to the database.
  final Batch batch = globals.db.batch();
  bool deleted = false;
  for (var local in filteredLocalEvents) {
    if (remoteEvents.indexWhere(
          (element) =>
              element.uid == local.uid && element.userId == local.userId,
        ) ==
        -1) {
      deleted = true;
      print("Local event doesn't exist in remote $local ${local.databaseId}");
      FirebaseAnalytics().logEvent(
        name: "RemoteDeletion",
        parameters: {
          "dataType": "events",
        },
      );
      batch.delete(
        "Events",
        where: "databaseId = ?",
        whereArgs: [local.databaseId],
      );
    }
  }
  if (deleted) {
    await batch.commit();
  }
}
