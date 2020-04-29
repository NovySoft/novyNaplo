import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';

// A function that inserts evals into the database
Future<void> insertEval(Evals eval) async {
  // Get a reference to the database.
  final Database db = await mainSql.database;

  await db.insert(
    'Evals',
    eval.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}