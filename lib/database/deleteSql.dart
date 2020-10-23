import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/mainSql.dart' as mainSql;

Future<void> deleteFromDb(int databaseId, String table) async {
  Crashlytics.instance.log("Delete from table: $table (id: $databaseId)");
  // Get a reference to the database.
  final db = await mainSql.database;

  await db.delete(
    table,
    where: "databaseId = ?",
    whereArgs: [databaseId],
  );
}

Future<void> clearAllTables() async {
  Crashlytics.instance.log("clearAllTables");
  // Get a reference to the database.
  final db = await mainSql.database;
  final batch = db.batch();
  batch.delete("Evals");
  batch.delete("Avarage");
  batch.delete("Notices");
  batch.delete("Events");
  batch.delete("Exams");
  batch.delete("Homework");
  batch.delete("Timetable");
  batch.delete("Absences");
  await batch.commit();
}
