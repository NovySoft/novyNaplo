import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/database/getSql.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/data/database/mainSql.dart' as mainSql;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/notificationHelper.dart' as notifHelper;

import 'evals.dart';
import 'notices.dart';

int notifId = 2;
//TODO: FIX first login notifications (disable them, when first time loging in)
//*Normal inserts

// A function that inserts evals into the database
Future<void> insertEval(Evals eval, {bool edited}) async {
  FirebaseCrashlytics.instance.log("insertSingleEval");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  //Get all evals, and see whether we should be just replacing
  List<Evals> allEvals = await getAllEvals();
  /*var matchedEvals = allEvals.where((element) {
    return (element.id == eval.id && element.form == eval.form) ||
        (element.subject == eval.subject &&
            element.id == eval.id &&
            element.form == eval.form);
  });
  if (matchedEvals.length == 0) {
    await db.insert(
      'Evals',
      eval.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (globals.notifications && edited != true) {
      notifId = notifId == 111 ? notifId + 2 : notifId + 1;
      await notifHelper.flutterLocalNotificationsPlugin.show(
        notifId,
        '${getTranslatedString("newMark")}: ' +
            capitalize(eval.subject) +
            " " +
            eval.value,
        '${getTranslatedString("theme")}: ' + eval.theme,
        notifHelper.platformChannelSpecifics,
        payload: "marks " + eval.id.toString(),
      );
    }
  } else {
    for (var n in matchedEvals) {
      //!Update didn't work so we delete and create a new one
      if (n.szamErtek != eval.szamErtek ||
          n.theme != eval.theme ||
          n.dateString != eval.dateString ||
          n.weight != eval.weight) {
        await deleteFromDb(n.databaseId, "Evals");
        if (globals.notifications) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            '${getTranslatedString("markModified")}: ' +
                capitalize(eval.subject) +
                " " +
                eval.value,
            '${getTranslatedString("theme")}: ' + eval.theme,
            notifHelper.platformChannelSpecifics,
            payload: "marks " + eval.id.toString(),
          );
        }
        insertEval(eval, edited: true);
      }
    }
  }*/
}

Future<void> insertHomework(Homework hw, {bool edited}) async {
  FirebaseCrashlytics.instance.log("insertSingleHw");
  /*// Get a reference to the database.
  final Database db = await mainSql.database;

  List<Homework> allHw = await getAllHomework();
  var matchedHw = allHw.where((element) {
    return (element.id == hw.id && element.subject == hw.subject);
  });

  DateTime afterDue = hw.dueDate;
  if (globals.howLongKeepDataForHw != -1) {
    afterDue =
        afterDue.add(Duration(days: globals.howLongKeepDataForHw.toInt()));
  }

  if (matchedHw.length == 0) {
    if (afterDue.isBefore(DateTime.now())) {
      print("OUT OF RANGE");
      if (hw.databaseId != null && globals.howLongKeepDataForHw != -1) {
        print("Deleted ${hw.databaseId}");
        await deleteFromDb(hw.databaseId, "Homework");
      }
      return;
    }
    await db.insert(
      'Homework',
      hw.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (globals.notifications && edited != true) {
      notifId = notifId == 111 ? notifId + 2 : notifId + 1;
      String subTitle = "${getTranslatedString("due")}: " +
          hw.dueDate.year.toString() +
          "-" +
          hw.dueDate.month.toString() +
          "-" +
          hw.dueDate.day.toString() +
          " " +
          parseIntToWeekdayString(hw.dueDate.weekday);
      if (afterDue.isAfter(DateTime.now())) {
        print("HW NOTIF");
        await notifHelper.flutterLocalNotificationsPlugin.show(
          notifId,
          '${getTranslatedString("newHw")}: ' + capitalize(hw.subject),
          subTitle,
          notifHelper.platformChannelSpecifics,
          payload: "hw " + hw.id.toString(),
        );
      }
    }
  } else {
    for (var n in matchedHw) {
      if (afterDue.compareTo(DateTime.now()) < 0) {
        print("OUT OF RANGE");
        if (n.databaseId != null && globals.howLongKeepDataForHw != -1) {
          print("Deleted ${n.databaseId}");
          await deleteFromDb(n.databaseId, "Homework");
        }
        return;
      }
      //!Update didn't work so we delete and create a new one
      if (n.content != hw.content ||
          n.dueDateString != hw.dueDateString ||
          n.givenUpString != hw.givenUpString) {
        await deleteFromDb(n.databaseId, "Homework");
        if (globals.notifications) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          String subTitle = "${getTranslatedString("due")}: " +
              hw.dueDate.year.toString() +
              "-" +
              hw.dueDate.month.toString() +
              "-" +
              hw.dueDate.day.toString() +
              " " +
              parseIntToWeekdayString(hw.dueDate.weekday);
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            '${getTranslatedString("hwModified")}: ' + capitalize(hw.subject),
            subTitle,
            notifHelper.platformChannelSpecifics,
            payload: "hw " + hw.id.toString(),
          );
        }
        insertHomework(hw, edited: true);
      }
    }
  }*/
}

Future<void> insertNotices(Notice notice, {bool edited}) async {
  FirebaseCrashlytics.instance.log("insertSingleNotice");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  List<Notice> allNotices = await getAllNotices();
  /*var matchedNotices = allNotices.where((element) {
    return (element.title == notice.title || element.id == notice.id);
  });
  if (matchedNotices.length == 0) {
    await db.insert(
      'Notices',
      notice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (globals.notifications && edited != true) {
      notifId = notifId == 111 ? notifId + 2 : notifId + 1;
      await notifHelper.flutterLocalNotificationsPlugin.show(
        notifId,
        '${getTranslatedString("newNotice")}: ' + capitalize(notice.title),
        notice.teacher,
        notifHelper.platformChannelSpecifics,
        payload: "notice " + notice.id.toString(),
      );
    }
  } else {
    for (var n in matchedNotices) {
      //!Update didn't work so we delete and create a new one
      if (n.title != notice.title || n.content != notice.content) {
        await deleteFromDb(n.databaseId, "Notices");
        if (globals.notifications) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            '${getTranslatedString("noticeModified")}: ' +
                capitalize(notice.title),
            notice.teacher,
            notifHelper.platformChannelSpecifics,
            payload: "notice " + notice.id.toString(),
          );
        }
        insertNotices(notice, edited: true);
      }
    }
  }*/
}

Future<void> insertAverage(Average average) async {
  FirebaseCrashlytics.instance.log("insertSingleAverage");
  /*// Get a reference to the database.
  final Database db = await mainSql.database;

  List<average> allAv = await getAllAverages();

  var matchedAv = allAv.where((element) {
    return (element.subject == average.subject);
  });
  if (matchedAv.length == 0) {
    await db.insert(
      'average',
      average.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    for (var n in matchedAv) {
      //!Update didn't work so we delete and create a new one
      if (n.ownValue != average.ownValue) {
        await deleteFromDb(n.databaseId, "average");
        if (globals.notifications) {
          String diff;
          if (average.ownValue == null || n.ownValue == null) {
            if (average.ownValue != null && n.ownValue == null) {
              diff = "+${average.ownValue.toStringAsFixed(3)}";
            } else {
              diff = "null";
            }
          } else {
            double diffValue = average.ownValue - n.ownValue;
            diff = diffValue > 0
                ? ("+${diffValue.toStringAsFixed(3)}")
                : diffValue.toStringAsFixed(3);
          }
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            '${getTranslatedString("avChanged")}: ' +
                capitalize(average.subject),
            '${getTranslatedString("newAv")}: ' +
                average.ownValue.toString() +
                " ($diff)",
            notifHelper.platformChannelSpecifics,
            payload: "average ${average.subject}",
          );
        }
        insertAverage(average);
      }
    }
  }*/
}

Future<void> insertExam(Exam exam, {bool edited}) async {
  FirebaseCrashlytics.instance.log("insertSingleExam");
  // Get a reference to the database.
  /*final Database db = await mainSql.database;

  List<Exam> allExam = await getAllExams();

  var matchedAv = allExam.where((element) {
    return (element.id == exam.id);
  });
  if (matchedAv.length == 0) {
    await db.insert(
      'Exams',
      exam.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (globals.notifications && edited != true) {
      notifId = notifId == 111 ? notifId + 2 : notifId + 1;
      await notifHelper.flutterLocalNotificationsPlugin.show(
        notifId,
        '${getTranslatedString("newExam")}: ' + capitalize(exam.nameOfExam),
        '${getTranslatedString("theme")}: ' + exam.subject,
        notifHelper.platformChannelSpecifics,
        payload: "exam " + exam.id.toString(),
      );
    }
  } else {
    for (var n in matchedAv) {
      //!Update didn't work so we delete and create a new one
      if (n.dateGivenUpString != exam.dateGivenUpString ||
          n.dateWriteString != exam.dateWriteString ||
          n.nameOfExam != exam.nameOfExam ||
          n.typeOfExam != exam.typeOfExam) {
        await deleteFromDb(n.databaseId, "Exams");
        if (globals.notifications) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            '${getTranslatedString("examModified")}: ' +
                capitalize(exam.nameOfExam),
            '${getTranslatedString("theme")}: ' + exam.subject,
            notifHelper.platformChannelSpecifics,
            payload: "exam " + exam.id.toString(),
          );
        }
        insertExam(exam, edited: true);
      }
    }
  }*/
}

//*Batch inserts

/*Future<void> batchInsertLessons(List<Lesson> lessonList,
    {bool lookAtDate = false}) async {
  FirebaseCrashlytics.instance.log("batchInsertLessons");
  bool inserted = false;
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();

  //Get all evals, and see whether we should be just replacing
  List<Lesson> allTimetable = await getAllTimetable();
  DateTime startMonday, endSunday;
  if (lookAtDate) {
    DateTime now = new DateTime.now();
    now = new DateTime(now.year, now.month, now.day);
    int monday = 1;
    int sunday = 7;
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
    }
    startMonday = now;
    now = new DateTime.now();
    now = new DateTime(now.year, now.month, now.day);
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
    }
    endSunday = now;
  }
  for (var lesson in lessonList) {
    if (lookAtDate) {
      if (!(lesson.date.compareTo(startMonday) >= 0 &&
          lesson.date.compareTo(endSunday) <= 0)) {
        return;
      }
    }
    var matchedLessons = allTimetable.where(
      (element) {
        return (element.id == lesson.id && element.subject == lesson.subject);
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
                n.dateString != lesson.dateString ||
                n.deputyTeacherName != lesson.deputyTeacherName ||
                n.name != lesson.name ||
                n.classroom != lesson.classroom ||
                n.homeWorkId != lesson.homeWorkId ||
                n.teacherHomeworkId != lesson.teacherHomeworkId ||
                json.encode(n.dogaIds) != json.encode(lesson.dogaIds) ||
                n.startDateString != lesson.startDateString ||
                n.endDateString != lesson.endDateString) &&
            n.id == lesson.id) {
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
          if (globals.notifications) {
            String subTitle = "";
            if (lesson.theme != null && lesson.theme != "") {
              subTitle = lesson.theme;
            } else if (lesson.teacher != null && lesson.teacher != "") {
              subTitle = lesson.teacher;
            } else if (lesson.deputyTeacherName != null &&
                lesson.deputyTeacherName != "") {
              subTitle = lesson.deputyTeacherName;
            } else {
              subTitle = lesson.classroom;
            }
            notifId = notifId == 111 ? notifId + 2 : notifId + 1;
            await notifHelper.flutterLocalNotificationsPlugin.show(
              notifId,
              '${getTranslatedString("editedLesson")}: ' +
                  capitalize(lesson.subject) +
                  " (${parseIntToWeekdayString(lesson.date.weekday)})",
              subTitle,
              notifHelper.platformChannelSpecifics,
              payload: "timetable " + lesson.id.toString(),
            );
          }
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }
}*/

Future<void> batchInsertExams(List<Exam> examList) async {
  FirebaseCrashlytics.instance.log("batchInsertExams");
  /*bool inserted = false;
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();

  List<Exam> allExam = await getAllExams();
  for (var exam in examList) {
    var matchedExams = allExam.where((element) {
      return (element.id == exam.id);
    });
    if (matchedExams.length == 0) {
      if (globals.notifications) {
        notifId = notifId == 111 ? notifId + 2 : notifId + 1;
        await notifHelper.flutterLocalNotificationsPlugin.show(
          notifId,
          '${getTranslatedString("newExam")}: ' + capitalize(exam.nameOfExam),
          '${getTranslatedString("theme")}: ' + exam.subject,
          notifHelper.platformChannelSpecifics,
          payload: "exam " + exam.id.toString(),
        );
      }
      inserted = true;
      batch.insert(
        'Exams',
        exam.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedExams) {
        //!Update didn't work so we delete and create a new one
        if (n.dateGivenUpString != exam.dateGivenUpString ||
            n.dateWriteString != exam.dateWriteString ||
            n.nameOfExam != exam.nameOfExam ||
            n.typeOfExam != exam.typeOfExam) {
          inserted = true;
          batch.delete(
            "Exams",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Exams',
            exam.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (globals.notifications) {
            notifId = notifId == 111 ? notifId + 2 : notifId + 1;
            await notifHelper.flutterLocalNotificationsPlugin.show(
              notifId,
              '${getTranslatedString("examModified")}: ' +
                  capitalize(exam.nameOfExam),
              '${getTranslatedString("theme")}: ' + exam.subject,
              notifHelper.platformChannelSpecifics,
              payload: "exam " + exam.id.toString(),
            );
          }
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }*/
}
