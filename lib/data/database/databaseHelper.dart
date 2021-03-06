import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/subjectColor.dart';
import 'package:novynaplo/data/models/subjectNicknames.dart';

import 'absences.dart' as absences;
import 'average.dart' as average;
import 'deleteSql.dart' as deleteSql;
import 'evals.dart' as evals;
import 'events.dart' as events;
import 'exam.dart' as exam;
import 'homework.dart' as homework;
import 'notices.dart' as notices;
import 'timetable.dart' as timetable;
import 'users.dart' as users;
import 'mainSql.dart' as main;
import 'colors.dart' as colors;
import 'subjects.dart' as subjects;

///List of pointers to the corresponding functions
class DatabaseHelper {
  static Future<List<List<Absence>>> Function() getAllAbsencesMatrix =
      absences.getAllAbsencesMatrix;
  static Future<void> Function(List<Absence>) batchInsertAbsences =
      absences.batchInsertAbsences;

  static Future<List<Average>> Function() getAllAverages =
      average.getAllAverages;
  static Future<void> Function(List<Average>) batchInsertAverages =
      average.batchInsertAverages;

  static Future<void> Function(int, String) deleteFromDbByID =
      deleteSql.deleteFromDbByID;
  static Future<void> Function() clearAllTables = deleteSql.clearAllTables;

  static Future<List<Evals>> Function() getAllEvals = evals.getAllEvals;
  static Future<void> Function(List<Evals>) batchInsertEvals =
      evals.batchInsertEvals;

  static Future<List<Event>> Function() getAllEvents = events.getAllEvents;
  static Future<void> Function(List<Event>) batchInsertEvents =
      events.batchInsertEvents;

  static Future<List<Exam>> Function() getAllExams = exam.getAllExams;
  static Future<void> Function(List<Exam>) batchInsertExams =
      exam.batchInsertExams;

  static Future<List<Homework>> Function({bool ignoreDue}) getAllHomework =
      homework.getAllHomework;
  static Future<void> Function(List<Homework>) batchInsertHomework =
      homework.batchInsertHomework;
  static Future<void> Function(Homework, {bool edited}) insertHomework =
      homework.insertHomework;

  static Future<List<Notice>> Function() getAllNotices = notices.getAllNotices;
  static Future<void> Function(List<Notice>) batchInsertNotices =
      notices.batchInsertNotices;

  static Future<List<Lesson>> Function() getAllTimetable =
      timetable.getAllTimetable;
  static Future<void> Function(List<Lesson>, {bool lookAtDate})
      batchInsertLessons = timetable.batchInsertLessons;

  static Future<void> Function(Student) insertUser = users.insertUser;
  static Future<List<Student>> Function({bool decrypt}) getAllUsers =
      users.getAllUsers;

  static Future<void> Function() initDatabase = main.initDatabase;

  static Future<void> Function(Student) updatePassword = users.updatePassword;

  static Future<void> Function(Student, bool) setFetched = users.setFetched;

  static Future<Map<String, int>> Function() getAllColors = colors.getAllColors;
  static Future<void> Function(String, int, String) insertColor =
      colors.insertColor;
  static Future<List<SubjectColor>> Function() getColorNames =
      colors.getColorNames;
  static Future<void> Function(String, int) updateColorCategory =
      colors.updateColorCategory;

  static Future<void> Function(Subject, String) insertSubject =
      subjects.insertSubject;
  static Future<Map<String, Subject>> Function() getSubjectMap =
      subjects.getSubjectMap;
  static Future<void> Function({
    @required String uid,
    @required int dbId,
    @required String subject,
    @required String dbName,
  }) updateSubject = subjects.updateSubject;
  static Future<List<List<SubjectNicknames>>> Function(bool isTimetable)
      getSubjNickMatrix = subjects.getSubjNickMatrix;
  static Future<void> Function(Subject subject) updateNickname =
      subjects.updateNickname;
}
