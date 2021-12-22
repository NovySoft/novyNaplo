import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/parseIntToWeekdayString.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:flutter/foundation.dart';

Future<List<Lesson>> getAllTimetable({
  bool userSpecific = false,
}) async {
  FirebaseCrashlytics.instance.log("getAllTimetable");

  List<Map<String, dynamic>> maps;
  if (userSpecific) {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Timetable WHERE userId = ? GROUP BY uid, userId ORDER BY databaseId',
      [globals.currentUser.userId],
    );
  } else {
    maps = await globals.db.rawQuery(
      'SELECT * FROM Timetable GROUP BY uid, userId ORDER BY databaseId',
    );
  }

  List<Lesson> outputTempList = List.generate(maps.length, (i) {
    Lesson temp = new Lesson.fromSqlite(maps[i]);
    return temp;
  });
  deleteOldLessonsFromList(outputTempList);
  return outputTempList;
}

void deleteOldLessonsFromList(List<Lesson> input) async {
  Batch batch = globals.db.batch();
  bool deleted = false;
  for (var item in List.from(input)) {
    DateTime date = item.endDate;
    if (item.databaseId != null) {
      //!Delete all lessons after a month of their ending
      date = date.add(Duration(days: 30));
      if (date.compareTo(DateTime.now()) < 0) {
        deleted = true;
        batch.delete(
          "Timetable",
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

Future<void> batchInsertLessons(
  List<Lesson> lessonList,
  Student userDetails, {
  bool lookAtDate = false,
}) async {
  FirebaseCrashlytics.instance.log("batchInsertLessons");
  bool inserted = false;
  final Batch batch = globals.db.batch();

  //Get all evals, and see whether we should be just replacing
  List<Lesson> allTimetable = await getAllTimetable();
  for (var lesson in lessonList) {
    //Don't insert lessons older than 30 days
    if (lookAtDate &&
        !(lesson.endDate
                .add(
                  Duration(days: 30),
                )
                .compareTo(
                  DateTime.now(),
                ) <
            0)) {
      var matchedLessons = allTimetable.where(
        (element) {
          return (element.uid == lesson.uid && element.userId == lesson.userId);
        },
      );

      if (matchedLessons.length == 0) {
        inserted = true;
        batch.insert(
          'Timetable',
          lesson.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        for (var n in matchedLessons) {
          //!Update didn't work so we delete and create a new one
          if ((n.theme != lesson.theme ||
                  n.teacher != lesson.teacher ||
                  n.deputyTeacher != lesson.deputyTeacher ||
                  n.name != lesson.name ||
                  n.classroom != lesson.classroom ||
                  n.teacherHwUid != lesson.teacherHwUid ||
                  json.encode(n.examUidList) !=
                      json.encode(lesson.examUidList) ||
                  n.startDate.toUtc().toIso8601String() !=
                      lesson.startDate.toUtc().toIso8601String() ||
                  n.endDate.toUtc().toIso8601String() !=
                      lesson.endDate.toUtc().toIso8601String()) &&
              n.uid == lesson.uid) {
            inserted = true;
            batch.delete(
              "Timetable",
              where: "databaseId = ?",
              whereArgs: [n.databaseId],
            );
            batch.insert(
              'Timetable',
              lesson.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            String subTitle = "";
            if (lesson.theme != null && lesson.theme != "") {
              subTitle = lesson.theme;
            } else if (lesson.teacher != null && lesson.teacher != "") {
              subTitle = lesson.teacher;
            } else if (lesson.deputyTeacher != null &&
                lesson.deputyTeacher != "") {
              subTitle = lesson.deputyTeacher;
            } else {
              subTitle = lesson.classroom;
            }
            if (lesson.subject != null) {
              if (userDetails.fetched)
                NotificationDispatcher.toBeDispatchedNotifications.timetables
                    .add(
                  NotificationData(
                    title:
                        '${(globals.allUsers.length == 1 ? getTranslatedString("editedLesson") : getTranslatedString(
                                "XsEditedLesson",
                                replaceVariables: [
                                  userDetails.nickname ?? userDetails.name
                                ],
                              ))}: ' +
                            capitalize(lesson.subject.name) +
                            " (${parseIntToWeekdayString(lesson.date.weekday)})",
                    subtitle: subTitle,
                    userId: lesson.userId,
                    uid: lesson.uid,
                    payload: "timetable ${lesson.userId} ${lesson.uid}",
                    isEdited: true,
                    additionalKey: parseIntToWeekdayString(lesson.date.weekday),
                  ),
                );
            }
          }
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }
  handleTimetableDeletion(
    remoteLessons: lessonList,
    localLessons: allTimetable,
    userDetails: userDetails,
  );
}

Future<void> handleTimetableDeletion({
  @required List<Lesson> remoteLessons,
  @required List<Lesson> localLessons,
  @required Student userDetails,
}) async {
  if (remoteLessons == null) return;
  List<Lesson> filteredLocalLessons = List.from(localLessons)
      .where((element) => element.userId == userDetails.userId)
      .toList()
      .cast<Lesson>();
  // Get a reference to the database.
  final Batch batch = globals.db.batch();
  bool deleted = false;
  for (var local in filteredLocalLessons) {
    if (remoteLessons.indexWhere(
              (element) =>
                  element.uid == local.uid && element.userId == local.userId,
            ) ==
            -1 &&
        remoteLessons.indexWhere(
              (element) => element.date.isSameDay(local.date),
            ) !=
            -1) {
      deleted = true;
      print(
        "Local timetable item doesn't exist in remote $local ${local.databaseId}",
      );
      FirebaseAnalytics.instance.logEvent(
        name: "RemoteDeletion",
        parameters: {
          "dataType": "timetable",
        },
      );
      batch.delete(
        "Timetable",
        where: "databaseId = ?",
        whereArgs: [local.databaseId],
      );
    }
  }
  if (deleted) {
    await batch.commit();
  }
}
