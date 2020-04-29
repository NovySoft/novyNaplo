import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';

Future<void> deleteFromDb(int databaseId, String table) async {
  // Get a reference to the database.
  final db = await mainSql.database;

  await db.delete(
    table,
    where: "databaseId = ?",
    whereArgs: [databaseId],
  );
}

Future<void> clearAllTables() async {
  // Get a reference to the database.
  final db = await mainSql.database;
  db.delete("Evals");
}
