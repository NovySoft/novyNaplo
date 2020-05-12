import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/database/getSql.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';
import 'package:collection/collection.dart';

Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;

//*Normal inserts
// A function that inserts evals into the database
Future<void> insertEval(Evals eval) async {
  Crashlytics.instance.log("insertSingleEval");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
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
  } else {
    for (var n in matchedEvals) {
      //!Update didn't work so we delete and create a new one
      if (n.numberValue != eval.numberValue ||
          n.theme != eval.theme ||
          n.dateString != eval.dateString ||
          n.weight != eval.weight) {
        deleteFromDb(n.databaseId, "Evals");
        insertEval(eval);
      }
    }
  }
}

Future<void> insertHomework(Homework hw) async {
  Crashlytics.instance.log("insertSingleHw");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
  List<Homework> allHw = await getAllHomework();
  var matchedHw = allHw.where((element) {
    return (element.id == hw.id && element.subject == hw.subject);
  });
  if (matchedHw.length == 0) {
    await db.insert(
      'Homework',
      hw.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    for (var n in matchedHw) {
      //!Update didn't work so we delete and create a new one
      if (n.content != hw.content ||
          n.dueDateString != hw.dueDateString ||
          n.givenUpString != hw.givenUpString) {
        deleteFromDb(n.databaseId, "Homework");
        insertHomework(hw);
      }
    }
  }
}

Future<void> insertNotices(Notices notice) async {
  Crashlytics.instance.log("insertSingleNotice");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
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
  } else {
    for (var n in matchedNotices) {
      //!Update didn't work so we delete and create a new one
      if (n.title != notice.title || n.content != notice.content) {
        deleteFromDb(n.databaseId, "Notices");
        insertNotices(notice);
      }
    }
  }
}

Future<void> insertAvarage(Avarage avarage) async {
  Crashlytics.instance.log("insertSingleAvarage");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
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
        deleteFromDb(n.databaseId, "Avarage");
        insertAvarage(avarage);
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
  await sleep1();
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
  await sleep1();
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
  await sleep1();
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
  await sleep1();
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
  await sleep1();
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
                n.dogaIds != lesson.dogaIds ||
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
        }
      }
    }
  }
  await batch.commit();
  //print("INSERTED EVAL BATCH");
}
