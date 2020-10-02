import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

Future<Database> database;

Future<void> initDatabase() async {
// Open the database and store the reference.
  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'NovyNalploDatabase.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) async {
      Crashlytics.instance.log("createSqlTables");
      // Run the CREATE TABLE statement on the database.
      await db.execute(
        "CREATE TABLE Evals (databaseId INTEGER PRIMARY KEY,id INTEGER,formName TEXT,form TEXT,value TEXT,numberValue INTEGER,teacher TEXT,'type' TEXT,subject TEXT,theme TEXT,mode TEXT,weight TEXT,dateString TEXT,createDateString TEXT)",
      );
      await db.execute(
        "CREATE TABLE Avarage (databaseId INTEGER PRIMARY KEY,subject TEXT,ownValue REAL)",
      );
      await db.execute(
        "CREATE TABLE Notices (databaseId INTEGER PRIMARY KEY,id INTEGER,title TEXT,content TEXT,teacher TEXT,dateString TEXT,subject TEXT)",
      );
      await db.execute(
        "CREATE TABLE Homework (databaseId INTEGER PRIMARY KEY,id INTEGER,classGroupId INTEGER,subject TEXT,teacher TEXT,content TEXT,givenUpString TEXT,dueDateString TEXT)",
      );
      await db.execute(
        "CREATE TABLE Timetable (databaseId INTEGER PRIMARY KEY,id INTEGER,subject TEXT,name TEXT,groupName TEXT,classroom TEXT,theme TEXT,teacher TEXT,deputyTeacherName TEXT,dogaNames TEXT,whichLesson INTEGER,homeWorkId INTEGER,teacherHomeworkId INTEGER,groupID INTEGER,dogaIds TEXT,homeworkEnabled BOOLEAN,date TEXT,startDate TEXT,endDate TEXT);",
      );
      await db.execute(
        "CREATE TABLE Exams (databaseId INTEGER PRIMARY KEY,id INTEGER,dateWriteString TEXT,dateGivenUpString TEXT,subject TEXT,teacher TEXT,nameOfExam TEXT,typeOfExam TEXT,classGroupId TEXT);",
      );
      await db.execute(
        "CREATE TABLE Events (databaseId INTEGER PRIMARY KEY, id INTEGER, dateString TEXT, endDateString TEXT, title TEXT, content TEXT);",
      );
    },

    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await db.execute(
        "CREATE TABLE IF NOT EXISTS Events (databaseId INTEGER PRIMARY KEY, id INTEGER, dateString TEXT, endDateString TEXT, title TEXT, content TEXT);",
      );
      await db.execute(
        "CREATE TABLE IF NOT EXISTS Exams (databaseId INTEGER PRIMARY KEY,id INTEGER,dateWriteString TEXT,dateGivenUpString TEXT,subject TEXT,teacher TEXT,nameOfExam TEXT,typeOfExam TEXT,classGroupId TEXT);",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 2,
  );
}
