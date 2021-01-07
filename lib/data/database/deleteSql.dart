import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/global.dart' as globals;

Future<void> deleteFromDbByID(int databaseId, String table) async {
  FirebaseCrashlytics.instance
      .log("Delete from table: $table (id: $databaseId)");
  // Get a reference to the database.
  final db = globals.db;

  await db.delete(
    table,
    where: "databaseId = ?",
    whereArgs: [databaseId],
  );
}

Future<void> clearAllTables() async {
  FirebaseCrashlytics.instance.log("clearAllTables");
  final batch = globals.db.batch();
  batch.delete("Evals");
  batch.delete("Average");
  batch.delete("Notices");
  batch.delete("Events");
  batch.delete("Exams");
  batch.delete("Homework");
  batch.delete("Timetable");
  batch.delete("Absences");
  batch.delete("Users");
  await batch.commit();
}
