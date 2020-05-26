import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/database/getSql.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/notificationHelper.dart' as notifHelper;
import 'package:novynaplo/functions/classManager.dart';
import 'package:collection/collection.dart';

Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
int notifId = 2;

//*Normal inserts
// A function that inserts evals into the database
Future<void> insertEval(Evals eval, {bool edited}) async {
  Crashlytics.instance.log("insertSingleEval");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  //Get all evals, and see whether we should be just replacing
  List<Evals> allEvals = await getAllEvals();
  var matchedEvals = allEvals.where((element) {
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
        'Új jegy: ' + capitalize(eval.subject) + " " + eval.value,
        'Téma: ' + eval.theme,
        notifHelper.platformChannelSpecifics,
        payload: "marks " + eval.id.toString(),
      );
    }
  } else {
    for (var n in matchedEvals) {
      //!Update didn't work so we delete and create a new one
      if (n.numberValue != eval.numberValue ||
          n.theme != eval.theme ||
          n.dateString != eval.dateString ||
          n.weight != eval.weight) {
        await deleteFromDb(n.databaseId, "Evals");
        if (globals.notifications) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            'Jegy módosult: ' + capitalize(eval.subject) + " " + eval.value,
            'Téma: ' + eval.theme,
            notifHelper.platformChannelSpecifics,
            payload: "marks " + eval.id.toString(),
          );
        }
        insertEval(eval, edited: true);
      }
    }
  }
}

Future<void> insertHomework(Homework hw, {bool edited}) async {
  Crashlytics.instance.log("insertSingleHw");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  List<Homework> allHw = await getAllHomework();
  var matchedHw = allHw.where((element) {
    return (element.id == hw.id && element.subject == hw.subject);
  });

  DateTime afterDue = hw.dueDate;
  if (globals.howLongKeepDataForHw != -1) {
    afterDue = afterDue.add(Duration(days: 15)); //Delete from DB after 15 days
  }

  if (matchedHw.length == 0) {
    if (afterDue.compareTo(DateTime.now()) < 0) {
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
      String subTitle = "Határidő: " +
          hw.dueDate.year.toString() +
          "-" +
          hw.dueDate.month.toString() +
          "-" +
          hw.dueDate.day.toString() +
          " " +
          parseIntToWeekdayString(hw.dueDate.weekday);
      await notifHelper.flutterLocalNotificationsPlugin.show(
        notifId,
        'Új házifeladat: ' + capitalize(hw.subject),
        subTitle,
        notifHelper.platformChannelSpecifics,
        payload: "hw " + hw.id.toString(),
      );
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
          String subTitle = "Határidő: " +
              hw.dueDate.year.toString() +
              "-" +
              hw.dueDate.month.toString() +
              "-" +
              hw.dueDate.day.toString() +
              " " +
              parseIntToWeekdayString(hw.dueDate.weekday);
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            'Módusolt házifeladat: ' + capitalize(hw.subject),
            subTitle,
            notifHelper.platformChannelSpecifics,
            payload: "hw " + hw.id.toString(),
          );
        }
        insertHomework(hw, edited: true);
      }
    }
  }
}

Future<void> insertNotices(Notices notice, {bool edited}) async {
  Crashlytics.instance.log("insertSingleNotice");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  List<Notices> allNotices = await getAllNotices();
  var matchedNotices = allNotices.where((element) {
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
        'Új feljegyzés: ' + capitalize(notice.title),
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
            'Feljegyzés módusolt: ' + capitalize(notice.title),
            notice.teacher,
            notifHelper.platformChannelSpecifics,
            payload: "notice " + notice.id.toString(),
          );
        }
        insertNotices(notice, edited: true);
      }
    }
  }
}

Future<void> insertAvarage(Avarage avarage) async {
  Crashlytics.instance.log("insertSingleAvarage");
  // Get a reference to the database.
  final Database db = await mainSql.database;

  List<Avarage> allAv = await getAllAvarages();

  var matchedAv = allAv.where((element) {
    return (element.subject == avarage.subject);
  });
  if (matchedAv.length == 0) {
    await db.insert(
      'Avarage',
      avarage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    for (var n in matchedAv) {
      //!Update didn't work so we delete and create a new one
      if (n.diff != avarage.diff ||
          n.ownValue != avarage.ownValue ||
          n.classValue != avarage.classValue) {
        await deleteFromDb(n.databaseId, "Avarage");
        if (globals.notifications) {
          double diffValue = avarage.ownValue - n.ownValue;
          String diff = diffValue > 0
              ? ("+${diffValue.toStringAsFixed(3)}")
              : diffValue.toStringAsFixed(3);
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          await notifHelper.flutterLocalNotificationsPlugin.show(
            notifId,
            'Átlag módosult: ' + capitalize(avarage.subject),
            'Új átlag: ' + avarage.ownValue.toString() + " ($diff)",
            notifHelper.platformChannelSpecifics,
            payload: "avarage 0",
          );
        }
        insertAvarage(avarage);
      }
    }
  }
}

Future<void> insertExam(Exam exam, {bool edited}) async {
  Crashlytics.instance.log("insertSingleExam");
  // Get a reference to the database.
  final Database db = await mainSql.database;

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
        'Új dolgozat: ' + capitalize(exam.nameOfExam),
        'Téma: ' + exam.subject,
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
            'Dolgozat módusolt: ' + capitalize(exam.nameOfExam),
            'Téma: ' + exam.subject,
            notifHelper.platformChannelSpecifics,
            payload: "exam " + exam.id.toString(),
          );
        }
        insertExam(exam, edited: true);
      }
    }
  }
}

//*Batch inserts
// A function that inserts multiple evals into the database
Future<void> batchInsertEval(List<Evals> evalList) async {
  Crashlytics.instance.log("batchInsertEval");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();

  //Get all evals, and see whether we should be just replacing
  List<Evals> allEvals = await getAllEvals();
  for (var eval in evalList) {
    var matchedEvals = allEvals.where(
      (element) {
        return (element.id == eval.id && element.form == eval.form) ||
            (element.subject == eval.subject &&
                element.id == eval.id &&
                element.form == eval.form);
      },
    );
    if (matchedEvals.length == 0) {
      batch.insert(
        'Evals',
        eval.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      //print("notifID: $notifId");
      if (globals.notifications) {
        notifId = notifId == 111 ? notifId + 2 : notifId + 1;
        await notifHelper.flutterLocalNotificationsPlugin.show(
          notifId,
          'Új jegy: ' + capitalize(eval.subject) + " " + eval.value,
          'Téma: ' + eval.theme,
          notifHelper.platformChannelSpecifics,
          payload: "marks " + eval.id.toString(),
        );
      }
    } else {
      for (var n in matchedEvals) {
        //!Update didn't work so we delete and create a new one
        if ((n.numberValue != eval.numberValue ||
                n.theme != eval.theme ||
                n.dateString != eval.dateString ||
                n.weight != eval.weight) &&
            n.id == eval.id) {
          batch.delete(
            "Evals",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Evals',
            eval.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          //print("notifID: $notifId");
          if (globals.notifications) {
            notifId = notifId == 111 ? notifId + 2 : notifId + 1;
            await notifHelper.flutterLocalNotificationsPlugin.show(
              notifId,
              'Jegy módosult: ' + capitalize(eval.subject) + " " + eval.value,
              'Téma: ' + eval.theme,
              notifHelper.platformChannelSpecifics,
              payload: "marks " + eval.id.toString(),
            );
          }
        }
      }
    }
  }
  await batch.commit();
  //print("INSERTED EVAL BATCH");
}

Future<void> batchInsertHomework(List<Homework> hwList) async {
  Crashlytics.instance.log("batchInsertHomework");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();

  List<Homework> allHw = await getAllHomework();
  for (var hw in hwList) {
    var matchedHw = allHw.where((element) {
      return (element.id == hw.id && element.subject == hw.subject);
    });
    if (matchedHw.length == 0) {
      batch.insert(
        'Homework',
        hw.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (globals.notifications) {
        notifId = notifId == 111 ? notifId + 2 : notifId + 1;
        String subTitle = "Határidő: " +
            hw.dueDate.year.toString() +
            "-" +
            hw.dueDate.month.toString() +
            "-" +
            hw.dueDate.day.toString() +
            " " +
            parseIntToWeekdayString(hw.dueDate.weekday);
        await notifHelper.flutterLocalNotificationsPlugin.show(
          notifId,
          'Új házifeladat: ' + capitalize(hw.subject),
          subTitle,
          notifHelper.platformChannelSpecifics,
          payload: "hw " + hw.id.toString(),
        );
      }
    } else {
      for (var n in matchedHw) {
        //!Update didn't work so we delete and create a new one
        if (n.content != hw.content ||
            n.dueDateString != hw.dueDateString ||
            n.givenUpString != hw.givenUpString) {
          batch.delete(
            "Homework",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Homework',
            hw.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (globals.notifications) {
            notifId = notifId == 111 ? notifId + 2 : notifId + 1;
            String subTitle = "Határidő: " +
                hw.dueDate.year.toString() +
                "-" +
                hw.dueDate.month.toString() +
                "-" +
                hw.dueDate.day.toString() +
                " " +
                parseIntToWeekdayString(hw.dueDate.weekday);
            await notifHelper.flutterLocalNotificationsPlugin.show(
              notifId,
              'Módusolt házifeladat: ' + capitalize(hw.subject),
              subTitle,
              notifHelper.platformChannelSpecifics,
              payload: "hw " + hw.id.toString(),
            );
          }
        }
      }
    }
  }
  await batch.commit();
}

Future<void> batchInsertAvarage(List<Avarage> avarageList) async {
  Crashlytics.instance.log("batchInsertAvarage");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();

  List<Avarage> allAv = await getAllAvarages();
  for (var avarage in avarageList) {
    var matchedAv = allAv.where((element) {
      return (element.subject == avarage.subject);
    });
    if (matchedAv.length == 0) {
      batch.insert(
        'Avarage',
        avarage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedAv) {
        //!Update didn't work so we delete and create a new one
        if (n.diff != avarage.diff ||
            n.ownValue != avarage.ownValue ||
            n.classValue != avarage.classValue) {
          batch.delete(
            "Avarage",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Avarage',
            avarage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (globals.notifications) {
            double diffValue = avarage.ownValue - n.ownValue;
            String diff = diffValue > 0
                ? ("+${diffValue.toStringAsFixed(3)}")
                : diffValue.toStringAsFixed(3);
            notifId = notifId == 111 ? notifId + 2 : notifId + 1;
            await notifHelper.flutterLocalNotificationsPlugin.show(
              notifId,
              'Átlag módosult: ' + capitalize(avarage.subject),
              'Új átlag: ' + avarage.ownValue.toString() + " ($diff)",
              notifHelper.platformChannelSpecifics,
              payload: "avarage 0",
            );
          }
        }
      }
    }
  }
  await batch.commit();
}

Future<void> batchInsertNotices(List<Notices> noticeList) async {
  Crashlytics.instance.log("batchInsertNotices");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();

  List<Notices> allNotices = await getAllNotices();
  for (var notice in noticeList) {
    var matchedNotices = allNotices.where((element) {
      return (element.title == notice.title || element.id == notice.id);
    });
    if (matchedNotices.length == 0) {
      batch.insert(
        'Notices',
        notice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (globals.notifications) {
        notifId = notifId == 111 ? notifId + 2 : notifId + 1;
        await notifHelper.flutterLocalNotificationsPlugin.show(
          notifId,
          'Új feljegyzés: ' + capitalize(notice.title),
          notice.teacher,
          notifHelper.platformChannelSpecifics,
          payload: "notice " + notice.id.toString(),
        );
      }
    } else {
      for (var n in matchedNotices) {
        //!Update didn't work so we delete and create a new one
        if ((n.title != notice.title || n.content != notice.content) &&
            n.id == notice.id) {
          batch.delete(
            "Notices",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Notices',
            notice.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (globals.notifications) {
            notifId = notifId == 111 ? notifId + 2 : notifId + 1;
            await notifHelper.flutterLocalNotificationsPlugin.show(
              notifId,
              'Feljegyzés módusolt: ' + capitalize(notice.title),
              notice.teacher,
              notifHelper.platformChannelSpecifics,
              payload: "notice " + notice.id.toString(),
            );
          }
        }
      }
    }
  }
  await batch.commit();
  //print("BATCH INSERTED NOTICES");
}

Future<void> batchInsertLessons(List<Lesson> lessonList) async {
  Crashlytics.instance.log("batchInsertEval");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();

  //Get all evals, and see whether we should be just replacing
  List<Lesson> allTimetable = await getAllTimetable();
  for (var lesson in lessonList) {
    var matchedLessons = allTimetable.where(
      (element) {
        return (element.id == lesson.id && element.subject == lesson.subject);
      },
    );
    if (matchedLessons.length == 0) {
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
              'Módusolt tanóra: ' +
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
  await batch.commit();
  //print("INSERTED EVAL BATCH");
}

Future<void> batchInsertExams(List<Exam> examList) async {
  Crashlytics.instance.log("batchInsertExam");
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
          'Új dolgozat: ' + capitalize(exam.nameOfExam),
          'Téma: ' + exam.subject,
          notifHelper.platformChannelSpecifics,
          payload: "exam " + exam.id.toString(),
        );
      }
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
              'Dolgozat módusolt: ' + capitalize(exam.nameOfExam),
              'Téma: ' + exam.subject,
              notifHelper.platformChannelSpecifics,
              payload: "exam " + exam.id.toString(),
            );
          }
        }
      }
    }
  }
  await batch.commit();
}

Future<void> batchInsertEvents(List<Event> eventList) async {
  Crashlytics.instance.log("batchInsertExam");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();
  List<Event> allExam = await getAllEvents();
  for (var event in eventList) {
    var matchedEvents = allExam.where((element) {
      return (element.id == event.id);
    });
    if (matchedEvents.length == 0) {
      if (globals.notifications) {
        notifId = notifId == 111 ? notifId + 2 : notifId + 1;
        await notifHelper.flutterLocalNotificationsPlugin.show(
          notifId,
          'Új dolog a faliújságon: ',
          event.title,
          notifHelper.platformChannelSpecifics,
          payload: "event " + event.id.toString(),
        );
      }
      batch.insert(
        'Events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedEvents) {
        //!Update didn't work so we delete and create a new one
        if (n.dateString != event.dateString ||
            n.endDateString != event.endDateString ||
            n.content != event.content ||
            n.title != event.title) {
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
          if (globals.notifications) {
            notifId = notifId == 111 ? notifId + 2 : notifId + 1;
            await notifHelper.flutterLocalNotificationsPlugin.show(
              notifId,
              'Faliújság módusolt:',
              event.title,
              notifHelper.platformChannelSpecifics,
              payload: "event " + event.id.toString(),
            );
          }
        }
      }
    }
  }
  await batch.commit();
}
