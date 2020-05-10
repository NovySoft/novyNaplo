import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';

//Give it the new eval and which id to replace
Future<void> updateEval(Evals eval, int replaceWhereDbId) async {
  // Get a reference to the database.
  final db = await mainSql.database;

  await db.update(
    'Evals',
    eval.toMap(),
    where: "databaseId = ?",
    whereArgs: [replaceWhereDbId],
  );
}
