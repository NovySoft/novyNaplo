import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/subjectNicknames.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:sqflite/sqflite.dart';

Future<void> insertSubjNick(Subject input) async {
  print("Write");
  FirebaseCrashlytics.instance.log("insertSubjNick");

  await globals.db.insert(
    'SubjNicks',
    {
      "subject": input.fullName,
      "nickname": input.name,
      "category": input.category.name,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<Map<String, String>> getAllSubjNicks() async {
  FirebaseCrashlytics.instance.log("readAllSubjNicks");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT subject, nickname FROM SubjNicks',
  );

  Map<String, String> output = new Map<String, String>();
  for (var i = 0; i < maps.length; i++) {
    output[maps[i]["subject"]] = maps[i]["nickname"];
  }

  return output;
}

Future<List<List<SubjectNicknames>>> getSubjNickMatrix() async {
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM SubjNicks',
  );

  List<List<SubjectNicknames>> output = [[]];
  List<SubjectNicknames> temp = [];
  for (var n in maps) {
    temp.add(
      SubjectNicknames(
        fullName: n["subject"],
        nickName: n["nickname"],
        category: n["category"],
      ),
    );
  }
  temp.sort((a, b) => a.category.compareTo(b.category));
  //Create matrix
  int index = 0;
  String categoryBefore = temp[0].category;
  for (var n in temp) {
    if (n.category != categoryBefore) {
      index++;
      output.last.sort((a, b) => a.fullName.compareTo(b.fullName));
      output.add([]);
      categoryBefore = n.category;
    }
    output[index].add(n);
  }

  return output;
}
