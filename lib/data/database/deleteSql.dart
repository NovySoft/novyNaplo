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
  batch.delete("Colors");
  batch.delete("Subjects");
  batch.delete("TrustedCerts");
  await batch.commit();
}

Future<void> deleteUsersData(int userId) async {
  FirebaseCrashlytics.instance.log("clearAllTables");
  final batch = globals.db.batch();
  batch.delete(
    "Evals",
    where: "userId = ?",
    whereArgs: [userId],
  );
  batch.delete(
    "Average",
    where: "userId = ?",
    whereArgs: [userId],
  );
  batch.delete(
    "Notices",
    where: "userId = ?",
    whereArgs: [userId],
  );
  batch.delete(
    "Events",
    where: "userId = ?",
    whereArgs: [userId],
  );
  batch.delete(
    "Exams",
    where: "userId = ?",
    whereArgs: [userId],
  );
  batch.delete(
    "Homework",
    where: "userId = ?",
    whereArgs: [userId],
  );
  batch.delete(
    "Timetable",
    where: "userId = ?",
    whereArgs: [userId],
  );
  batch.delete(
    "Absences",
    where: "userId = ?",
    whereArgs: [userId],
  );
  await batch.commit();
}
