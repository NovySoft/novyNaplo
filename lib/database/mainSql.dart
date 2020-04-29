import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

Future<Database> database;

void initDatabase() async {
// Open the database and store the reference.
  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'NovyNalploDatabase.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      db.execute(
        "CREATE TABLE Evals (databaseId INTEGER PRIMARY KEY,id INTEGER,formName TEXT,form TEXT,value TEXT,numberValue INTEGER,teacher TEXT,'type' TEXT,subject TEXT,theme TEXT,mode TEXT,weight TEXT,dateString TEXT,createDateString TEXT)",
      );
      db.execute(
        "CREATE TABLE Avarage (databaseId INTEGER PRIMARY KEY,subject TEXT,ownValue REAL,classValue REAL,diff REAL)",
      );
      db.execute(
        "CREATE TABLE Notices (databaseId INTEGER PRIMARY KEY,id INTEGER,title TEXT,content TEXT,teacher TEXT,dateString TEXT,subject TEXT)",
      );
      db.execute(
        "CREATE TABLE Homework (databaseId INTEGER PRIMARY KEY,id INTEGER,classGroupId INTEGER,subject TEXT,teacher TEXT,content TEXT,givenUpString TEXT,dueDateString TEXT)",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}
