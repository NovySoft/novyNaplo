import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/functions/classManager.dart';

// A method that retrieves all the evals from the table.
Future<List<Evals>> getAllEvals() async {
  // Get a reference to the database.
  final Database db = await mainSql.database;

  // Query the table for all the evals.
  final List<Map<String, dynamic>> maps = await db.query('Evals');

  // Convert the List<Map<String, dynamic> into a List<Evals>.
  return List.generate(maps.length, (i) {
    Evals temp = new Evals();
    temp.id = maps[i]['id'];
    temp.formName = maps[i]['formName'];
    temp.form = maps[i]['form'];
    temp.value = maps[i]['value'];
    temp.numberValue = maps[i]['numberValue'];
    temp.teacher = maps[i]['teacher'];
    temp.type = maps[i]['type'];
    temp.subject = maps[i]['subject'];
    temp.theme = maps[i]['theme'];
    temp.mode = maps[i]['mode'];
    temp.weight = maps[i]['weight'];
    temp.databaseId = maps[i]['databaseId'];
    temp.dateString = maps[i]['dateString'];
    temp.createDateString = maps[i]['createDateString'];
    return temp;
  });
}
