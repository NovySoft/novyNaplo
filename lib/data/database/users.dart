import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/data/decryptionHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;

Future<void> insertUser(Student user) async {
  FirebaseCrashlytics.instance.log("insertUser");
  await globals.db.insert(
    'Users',
    user.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Student>> getAllUsers({bool decrypt = true}) async {
  FirebaseCrashlytics.instance.log("getAllUsers");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Users',
  );

  List<Student> tempList = List.generate(maps.length, (i) {
    Student temp = new Student(
      userId: maps[i]['id'],
      uid: maps[i]['uid'],
      mothersName: maps[i]['mothersName'],
      addressList: json.decode(maps[i]['adressList']).cast<String>(),
      parents: Parent.fromJsonList(maps[i]['parents']),
      name: maps[i]['name'],
      nickname: maps[i]['nickname'],
      birthDay: maps[i]['birthDay'],
      placeOfBirth: maps[i]['placeOfBirth'],
      birthName: maps[i]['birthName'],
      schoolYearUid: maps[i]['schoolYearUid'],
      bankAccount: BankAccount.fromJson(json.decode(maps[i]['bankAccount'])),
      institution: Institution.fromJson(json.decode(maps[i]['institution'])),
      school: maps[i]['school'],
      username: maps[i]['username'],
      password: maps[i]['password'],
      iv: maps[i]['iv'],
      current: maps[i]['current'] == 1 ? true : false,
      fetched: maps[i]['fetched'] == 1 ? true : false,
    );
    if (decrypt) {
      return decryptUserDetails(temp);
    }
    return temp;
  });
  return tempList;
}

Future<String> getUsersNameFromUserId(int userId) async {
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT name, nickname FROM Users WHERE id = ?',
    [userId],
  );
  if (maps[0]["nickname"] == null) {
    return maps[0]["name"];
  } else {
    return maps[0]["nickname"];
  }
}

Future<void> updatePassword(Student user) async {
  FirebaseCrashlytics.instance.log("updatePassword");
  await globals.db.rawUpdate(
    "UPDATE Users SET password = ? WHERE id = ? OR uid = ?",
    [user.password, user.userId, user.uid],
  );
}

Future<void> setFetched(Student user, bool value) async {
  await globals.db.rawUpdate(
    "UPDATE Users SET fetched = ? WHERE id = ? OR uid = ?",
    [value ? 1 : 0, user.userId, user.uid],
  );
}
