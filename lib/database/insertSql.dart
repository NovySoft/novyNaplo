import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/database/getSql.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';

// A function that inserts evals into the database
Future<void> insertEval(Evals eval) async {
  // Get a reference to the database.
  final Database db = await mainSql.database;

  //Get all evals, and see whether we should be just replacing
  List<Evals> allEvals = await getAllEvals();
  var matchedEvals = allEvals.where((element) {
    return (element.id == eval.id && element.form == eval.form) ||
        (element.subject == eval.subject &&
            element.id == eval.id &&
            element.dateString == eval.dateString &&
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
      if (n != eval) {
        deleteFromDb(n.databaseId, "Evals");
        n.databaseId = null;
        insertEval(eval);
      }
    }
  }
}
