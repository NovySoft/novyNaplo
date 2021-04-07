import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/subjectColor.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart' as subjCol;

Future<Map<String, int>> getAllColors() async {
  FirebaseCrashlytics.instance.log("getAllColors");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT id, color FROM Colors',
  );
  Map<String, int> output = new Map<String, int>();
  //Ez nem tudom mi a tök, de nem érdekel, mert működik
  for (var i = 0; i < maps.length; i++) {
    output[maps[i]["id"]] = maps[i]["color"];
  }
  return output;
}

Future<void> insertColor(String id, int color, String category) async {
  FirebaseCrashlytics.instance.log("insertColor");

  await globals.db.insert(
    'Colors',
    {
      "id": id,
      "color": color,
      "category": category,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  subjCol.subjectColorList = await getColorNames();
}

Future<List<SubjectColor>> getColorNames() async {
  FirebaseCrashlytics.instance.log("getColorNames");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Colors',
  );
  List<SubjectColor> output = [];

  for (var n in maps) {
    output.add(
      SubjectColor(
        id: n["id"],
        color: n["color"],
        category: n["category"],
      ),
    );
  }

  return output;
}

Future<void> updateColorCategory(String categoryName, int color) async {
  FirebaseCrashlytics.instance.log("insertColor");

  await globals.db.rawQuery(
    "UPDATE Colors SET color = ? WHERE category = ?",
    [color, categoryName],
  );

  subjCol.subjectColorList = await getColorNames();
}
