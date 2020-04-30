import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/database/getSql.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';

// A function that inserts evals into the database
Future<void> insertEval(Evals eval) async {
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
    eval.databaseId = null;
    await db.insert(
      'Evals',
      eval.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    for (var n in matchedEvals) {
      //!Update didn't work so we delete and create a new one
      //TODO this isn't the best solution, but it works for now. FIX it later
      if (n.numberValue != eval.numberValue ||
          n.theme != eval.theme ||
          n.dateString != eval.dateString ||
          n.weight != eval.weight) {
        deleteFromDb(n.databaseId, "Evals");
        n.databaseId = null;
        insertEval(eval);
      }
    }
  }
}

Future<void> insertHomework(Homework hw) async {
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
  List<Homework> allHw = await getAllHomework();
  var matchedHw = allHw.where((element) {
    return (element.id == hw.id && element.subject == hw.subject);
  });
  if (matchedHw.length == 0) {
    hw.databaseId = null;
    await db.insert(
      'Homework',
      hw.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    for (var n in matchedHw) {
      //!Update didn't work so we delete and create a new one
      if (n.content != hw.content || n.dueDateString != hw.dueDateString) {
        deleteFromDb(n.databaseId, "Homework");
        n.databaseId = null;
        insertHomework(hw);
      }
    }
  }
}

Future<void> insertNotices(Notices notice) async {
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
  List<Notices> allNotices = await getAllNotices();
  var matchedNotices = allNotices.where((element) {
    return (element.title == notice.title || element.id == notice.id);
  });
  if (matchedNotices.length == 0) {
    notice.databaseId = null;
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
        n.databaseId = null;
        insertNotices(notice);
      }
    }
  }
}

Future<void> insertAvarage(Avarage avarage) async {
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
  List<Avarage> allAv = await getAllAvarages();
  print("Call db on AV");

  var matchedAv = allAv.where((element) {
    return (element.subject == avarage.subject);
  });
  if (matchedAv.length == 0) {
    print("INSERT AV");
    avarage.databaseId = null;
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
        print("UPDATE AV");
        deleteFromDb(n.databaseId, "Avarage");
        n.databaseId = null;
        insertAvarage(avarage);
      }
    }
  }
}
