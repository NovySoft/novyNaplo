import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;

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
  final batch = db.batch();
  batch.delete("Evals");
  batch.delete("Avarage");
  batch.delete("Notices");
  batch.delete("Homework");
  await batch.commit();
}
