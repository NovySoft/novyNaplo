import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/database/mainSql.dart' as mainSql;
import 'package:novynaplo/data/models/evals.dart';

//Give it the new eval and which id to replace
Future<void> updateEval(Evals eval, int replaceWhereDbId) async {
  FirebaseCrashlytics.instance.log("updateEval");
  /*// Get a reference to the database.
  final db = await mainSql.database;

  await db.update(
    'Evals',
    eval.toMap(),
    where: "databaseId = ?",
    whereArgs: [replaceWhereDbId],
  );*/
}
