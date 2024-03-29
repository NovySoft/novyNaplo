import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';

Future<Database> database;

Future<void> initDatabase() async {
// Open the database and store the reference.
  String dbPath = await getDatabasesPath();
  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(dbPath, 'NovyNaploDatabaseV2.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) async {
      FirebaseCrashlytics.instance.log("createSqlTables");
      // Run the CREATE TABLE statement on the database.
      await db.execute(
        'CREATE TABLE Evals (databaseId INTEGER PRIMARY KEY,uid TEXT,teacher TEXT,valueType TEXT,kindOf TEXT,createDate TEXT,seenDate TEXT,mode TEXT,date TEXT,weight INTEGER,numberValue REAL,textValue TEXT,shortTextValue TEXT,subject TEXT,theme TEXT,"type" TEXT,"group" TEXT,classAv REAL,sortIndex INTEGER,userId INTEGER);',
      );
      await db.execute(
        "CREATE TABLE Average (databaseId INTEGER PRIMARY KEY,subject TEXT,ownValue REAL,classValue REAL DEFAULT 0 NOT NULL,userId INTEGER);",
      );
      await db.execute(
        'CREATE TABLE Notices (databaseId INTEGER PRIMARY KEY,title TEXT,date TEXT,createDate TEXT,teacher TEXT,seenDate TEXT,"group" TEXT,content TEXT,subject TEXT,"type" TEXT,uid TEXT,userId INTEGER);',
      );
      await db.execute(
        'CREATE TABLE Homework (databaseId INTEGER PRIMARY KEY,uid TEXT,attachments TEXT,date TEXT,dueDate TEXT,createDate TEXT,isTeacherHW INTEGER,isStudentHomeworkEnabled INTEGER,isSolved INTEGER,teacher TEXT,content TEXT,subject TEXT,"group" TEXT,userId INTEGER);',
      );
      await db.execute(
        'CREATE TABLE Timetable (databaseId INTEGER PRIMARY KEY,uid TEXT,state TEXT,examUidList TEXT,examUid TEXT,date TEXT,deputyTeacher TEXT,isStudentHomeworkEnabled INTEGER,startDate TEXT,name TEXT,lessonNumberDay INTEGER,lessonNumberYear INTEGER,"group" TEXT,teacherHwUid TEXT,isHWSolved INTEGER,teacher TEXT,subject TEXT,presence TEXT,theme TEXT,classroom TEXT,"type" TEXT,endDate TEXT,attachments TEXT,isSpecialDayEvent INTEGER,userId INTEGER);',
      );
      await db.execute(
        'CREATE TABLE Exams (databaseId INTEGER PRIMARY KEY,uid TEXT,announcementDate TEXT,dateOfWriting TEXT,mode TEXT,lessonNumber INTEGER,teacher TEXT,subject TEXT,"group" TEXT,theme TEXT,userId INTEGER);',
      );
      await db.execute(
        "CREATE TABLE Events (databaseId INTEGER PRIMARY KEY,uid TEXT,startDate TEXT,endDate TEXT,title TEXT,content TEXT,userId INTEGER);",
      );
      await db.execute(
        'CREATE TABLE Absences (databaseId INTEGER PRIMARY KEY,uid TEXT,justificationState TEXT,justificationType TEXT,delayInMinutes INTEGER,mode TEXT,date TEXT,lesson TEXT,teacher TEXT,subject TEXT,"type" TEXT,"group" TEXT,createDate TEXT,userId INTEGER);',
      );
      await db.execute(
        'CREATE TABLE Users (id INTEGER PRIMARY KEY,uid TEXT,mothersName TEXT,adressList TEXT,parents TEXT,name TEXT,nickname TEXT,birthDay TEXT,placeOfBirth TEXT,birthName TEXT,schoolYearUid TEXT,bankAccount TEXT,institution TEXT,username TEXT,password TEXT,school TEXT,iv TEXT,color INTEGER DEFAULT (4294940672),"current" INTEGER DEFAULT 0,fetched INTEGER DEFAULT 0);',
      );
      await db.execute(
        'CREATE TABLE Colors (id TEXT PRIMARY KEY,color INTEGER,category TEXT);',
      );
      await db.execute(
        'CREATE TABLE Subjects (uid TEXT PRIMARY KEY,category TEXT,nickname TEXT, fullname TEXT, teacher TEXT);',
      );
      await db.execute(
        'CREATE TABLE TrustedCerts (radixModulus TEXT, exponent INTEGER, subject TEXT, date TEXT);',
      );
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion <= 5) {
        // Created in version 6 already (testing version)
        await db.execute(
          "ALTER TABLE Users ADD color INTEGER DEFAULT (4294940672);",
        );
      }
      // Append colors to existing users
      List<Map<String, dynamic>> users =
          await db.rawQuery('SELECT id FROM Users');

      if (users.length > 1) {
        // Enable coloring for multi user
        await globals.prefs.setBool('appBarColoredByUser', true);
        globals.appBarColoredByUser = true;

        for (int i = 0; i < users.length; i++) {
          await db.execute(
            "UPDATE Users SET color = ? WHERE id = ?;",
            [
              myListOfRandomColors[i % myListOfRandomColors.length].value,
              users[i]["id"],
            ],
          );
        }
      } else if (users.length == 1) {
        await db.execute(
          "UPDATE Users SET color = ? WHERE id = ?;",
          [
            Colors.orange.value,
            users[0]["id"],
          ],
        );
      }
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 7,
  );
  globals.db = await database;
}
