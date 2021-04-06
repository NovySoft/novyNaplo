import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:sqflite/sqflite.dart';

Future<Map<String, int>> getAllColors() async {
  FirebaseCrashlytics.instance.log("getAllColors");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Colors',
  );
  Map<String, int> output = new Map<String, int>();
  //Ez nem tudom mi a tök, de nem érdekel, mert működik
  for (var i = 0; i < maps.length; i++) {
    output[maps[i]["id"]] = maps[i]["color"];
  }
  return output;
}

Future<void> insertColor(String id, int color, String name) async {
  FirebaseCrashlytics.instance.log("insertColor");

  await globals.db.insert(
    'Colors',
    {
      "id": id,
      "color": color,
      "name": name,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<Map<String, String>> getColorNames() async {
  FirebaseCrashlytics.instance.log("getColorNames");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT id, name FROM Colors',
  );
  Map<String, String> output = new Map<String, String>();
  for (var i = 0; i < maps.length; i++) {
    output[maps[i]["id"]] = maps[i]["name"];
  }

  return output;
}
