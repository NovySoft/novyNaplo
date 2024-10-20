import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;
import 'databaseHelper.dart';

Future<void> updateToken(Student user) async {
  FirebaseCrashlytics.instance.log("updateToken");
  print("New token: ${user.username}-${user.school} ${user.refreshToken}");
  await globals.db.rawUpdate(
    // Uses username and school so it can be used even during login
    "UPDATE Users SET refreshToken = ? WHERE username = ? AND school = ?",
    [user.refreshToken, user.username, user.school],
  );
}

Future<void> insertUser(Student user) async {
  FirebaseCrashlytics.instance.log("insertUser");
  await globals.db.insert(
    'Users',
    user.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<Student> getUserById(int id) async {
  FirebaseCrashlytics.instance.log("getAllUsers");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Users WHERE id = ?',
    [id],
  );
  if (maps.length == 0) {
    throw "No user with id $id was found!";
  }
  Student temp = new Student.fromSqlite(maps[0]);
  return temp;
}

Future<List<Student>> getAllUsers() async {
  FirebaseCrashlytics.instance.log("getAllUsers");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Users',
  );

  List<Student> tempList = List.generate(maps.length, (i) {
    Student temp = new Student.fromSqlite(maps[i]);
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

Future<void> changeNickname(Student user, String nickname) async {
  FirebaseCrashlytics.instance.log("changeNickname");
  String nickanameToBeSet = nickname;
  if (nickanameToBeSet.length == 0) nickanameToBeSet = null;
  await globals.db.rawUpdate(
    "UPDATE Users SET nickname = ? WHERE id = ? OR uid = ?",
    [nickanameToBeSet, user.userId, user.uid],
  );
  globals.allUsers
      .firstWhere(
        (element) => element.userId == user.userId || element.uid == user.uid,
      )
      .nickname = nickanameToBeSet;
  if (user.current) {
    globals.currentUser.nickname = nickanameToBeSet;
  }
}

Future<void> setCurrentUser(int newCurrentUserId) async {
  FirebaseCrashlytics.instance.log("setCurrentUser");
  await globals.db.rawUpdate(
    "UPDATE Users SET current = 0",
  );
  await globals.db.rawUpdate(
    "UPDATE Users SET current = 1 WHERE id = ?",
    [newCurrentUserId],
  );
}

Future<void> updateKretaGivenParameters(Student user) async {
  FirebaseCrashlytics.instance.log("updateKretaGivenParameters");
  if (user.userId == null) return;

  Student tempStudent = Student.from(user);
  tempStudent.current = false;
  tempStudent.fetched = true;

  Map<String, dynamic> updateObject = tempStudent.toMap();
  // Remove internal stuff....
  updateObject.remove('id');
  updateObject.remove('nickname');
  updateObject.remove('username');
  updateObject.remove('password');
  updateObject.remove('school');
  updateObject.remove('iv');
  updateObject.remove('current');
  updateObject.remove('fetched');
  updateObject.remove('color');

  await globals.db.update(
    "Users",
    updateObject,
    where: "id = ?",
    whereArgs: [user.userId],
  );
}

Future<void> batchUpdateUserPositions(List<Student> userList) async {
  FirebaseCrashlytics.instance.log("batchUpdateUserPositions");

  final Batch batch = globals.db.batch();
  for (Student user in userList) {
    batch.update(
      "Users",
      {
        'institution': user.institution.toJson(),
      },
      where: "id = ?",
      whereArgs: [user.userId],
    );
  }
  await batch.commit();
}

Future<void> deleteUserAndAssociatedData(Student user) async {
  FirebaseCrashlytics.instance.log("deleteUserAndAssociatedData");
  await globals.db.delete(
    "Users",
    where: "id = ?",
    whereArgs: [user.userId],
  );
  if (user.current) {
    if (globals.allUsers.length > 0) {
      print(
        "Deleted user is current user too, new currUser: ${globals.allUsers[0].name}",
      );
      await DatabaseHelper.setCurrentUser(globals.allUsers[0].userId);
      globals.currentUser = globals.allUsers[0];
    }
  }
  DatabaseHelper.deleteUsersData(user.userId);
}

Future<void> changeUserColor(Student user, Color newColor) async {
  FirebaseCrashlytics.instance.log("changeUserColor");
  await globals.db.update(
    "Users",
    {
      'color': newColor.value,
    },
    where: "id = ?",
    whereArgs: [user.userId],
  );
}