import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

Future<Database> database;

Future<void> initDatabase() async {
// Open the database and store the reference.
  String dbPath = await getDatabasesPath();
  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(dbPath, 'NovyNalploDatabaseV2.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) async {
      FirebaseCrashlytics.instance.log("createSqlTables");
      //Delete old database
      String path = join(dbPath, 'NovyNalploDatabase.db');
      File file = new File(path);
      if (file.existsSync()) {
        file.delete();
      }
      // Run the CREATE TABLE statement on the database.
      await db.execute(
        'CREATE TABLE Evals (databaseId INTEGER PRIMARY KEY,uid TEXT,teacher TEXT,valueType TEXT,kindOf TEXT,createDate TEXT,seenDate TEXT,mode TEXT,date TEXT,weight INTEGER,numberValue INTEGER,textValue TEXT,shortTextValue TEXT,subject TEXT,theme TEXT,"type" TEXT,"group" TEXT,sortIndex INTEGER,userId INTEGER);',
      );
      await db.execute(
        "CREATE TABLE Average (databaseId INTEGER PRIMARY KEY,subject TEXT,value REAL,userId INTEGER);",
      );
      await db.execute(
        'CREATE TABLE Notices (databaseId INTEGER PRIMARY KEY,title TEXT,date TEXT,createDate TEXT,teacher TEXT,seenDate TEXT,"group" TEXT,content TEXT,subject TEXT,"type" TEXT,uid TEXT,userId INTEGER);',
      );
      await db.execute(
        'CREATE TABLE Homework (databaseId INTEGER PRIMARY KEY,uid TEXT,attachments TEXT,date TEXT,dueDate TEXT,createDate TEXT,isTeacherHW INTEGER,isStudentHomeworkEnabled INTEGER,isSolved INTEGER,teacher TEXT,content TEXT,subject TEXT,"group" TEXT,userId INTEGER);',
      );
      await db.execute(
        "CREATE TABLE Timetable (databaseId INTEGER PRIMARY KEY,id INTEGER,subject TEXT,name TEXT,groupName TEXT,classroom TEXT,theme TEXT,teacher TEXT,deputyTeacherName TEXT,dogaNames TEXT,whichLesson INTEGER,homeWorkId INTEGER,teacherHomeworkId INTEGER,groupID INTEGER,dogaIds TEXT,homeworkEnabled BOOLEAN,date TEXT,startDate TEXT,endDate TEXT,userId INTEGER);",
      );
      await db.execute(
        "CREATE TABLE Exams (databaseId INTEGER PRIMARY KEY,id INTEGER,dateWriteString TEXT,dateGivenUpString TEXT,subject TEXT,teacher TEXT,nameOfExam TEXT,typeOfExam TEXT,classGroupId TEXT,userId INTEGER);",
      );
      await db.execute(
        "CREATE TABLE Events (databaseId INTEGER PRIMARY KEY,uid TEXT,startDate TEXT,endDate TEXT,title TEXT,content TEXT,userId INTEGER);",
      );
      await db.execute(
        'CREATE TABLE Absences (databaseId INTEGER PRIMARY KEY,uid TEXT,justificationState TEXT,justificationType TEXT,delayInMinutes INTEGER,mode TEXT,date TEXT,lesson TEXT,teacher TEXT,subject TEXT,"type" TEXT,"group" TEXT,createDate TEXT,userId INTEGER);',
      );
      await db.execute(
        'CREATE TABLE Users (id INTEGER PRIMARY KEY,uid TEXT,mothersName TEXT,adressList TEXT,parents TEXT,name TEXT,birthDay TEXT,placeOfBirth TEXT,birthName TEXT,schoolYearUid TEXT,bankAccount TEXT,institution TEXT,username TEXT,password TEXT,school TEXT,iv TEXT,"current" INTEGER DEFAULT 0);',
      );
    },

    onUpgrade: (Database db, int oldVersion, int newVersion) async {},
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}
