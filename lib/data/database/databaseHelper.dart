import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/kretaCert.dart';
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
import 'trustedCerts.dart' as trustedCerts;

///List of pointers to the corresponding functions
class DatabaseHelper {
  static Future<List<List<Absence>>> Function({bool userSpecific})
      getAllAbsencesMatrix = absences.getAllAbsencesMatrix;
  static Future<void> Function(List<Absence>, Student) batchInsertAbsences =
      absences.batchInsertAbsences;

  static Future<List<Average>> Function() getAllAverages =
      average.getAllAverages;
  static Future<void> Function(List<Average>, Student) batchInsertAverages =
      average.batchInsertAverages;
  static Future<Map<String, double>> Function() getClassAverages =
      average.getClassAverages;

  static Future<void> Function(int, String) deleteFromDbByID =
      deleteSql.deleteFromDbByID;
  static Future<void> Function() clearAllTables = deleteSql.clearAllTables;
  static Future<void> Function(int) deleteUsersData = deleteSql.deleteUsersData;

  static Future<List<Evals>> Function({bool userSpecific}) getAllEvals =
      evals.getAllEvals;
  static Future<void> Function(List<Evals>, Student) batchInsertEvals =
      evals.batchInsertEvals;
  static Future<double> Function(int, String) getEvalAssocedClassAv =
      evals.getEvalAssocedClassAv;

  static Future<List<Event>> Function({bool userSpecific}) getAllEvents =
      events.getAllEvents;
  static Future<void> Function(List<Event>, Student) batchInsertEvents =
      events.batchInsertEvents;

  static Future<List<Exam>> Function({bool userSpecific}) getAllExams =
      exam.getAllExams;
  static Future<void> Function(List<Exam>, Student) batchInsertExams =
      exam.batchInsertExams;

  static Future<List<Homework>> Function({bool ignoreDue, bool userSpecific})
      getAllHomework = homework.getAllHomework;
  static Future<void> Function(List<Homework>, Student) batchInsertHomework =
      homework.batchInsertHomework;
  static Future<void> Function(Homework, Student, {bool edited})
      insertHomework = homework.insertHomework;
  static Future<int> Function(String) getHomeworkUser =
      homework.getHomeworkUser;

  static Future<List<Notice>> Function({bool userSpecific}) getAllNotices =
      notices.getAllNotices;
  static Future<void> Function(List<Notice>, Student) batchInsertNotices =
      notices.batchInsertNotices;

  static Future<List<Lesson>> Function({bool userSpecific}) getAllTimetable =
      timetable.getAllTimetable;
  static Future<void> Function(List<Lesson>, Student, {bool lookAtDate})
      batchInsertLessons = timetable.batchInsertLessons;

  static Future<void> Function(Student) insertUser = users.insertUser;
  static Future<List<Student>> Function({bool decrypt}) getAllUsers =
      users.getAllUsers;
  static Future<Student> Function(int id, {bool decrypt}) getUserById =
      users.getUserById;
  static Future<void> Function(Student, String) changeNickname =
      users.changeNickname;
  static Future<void> Function(int) setCurrentUser = users.setCurrentUser;
  static Future<void> Function(Student) updateKretaGivenParameters =
      users.updateKretaGivenParameters;
  static Future<void> Function(List<Student>) batchUpdateUserPositions =
      users.batchUpdateUserPositions;
  static Future<void> Function(Student) deleteUserAndAssociatedData =
      users.deleteUserAndAssociatedData;

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

  static Future<List<KretaCert>> Function() getTrustedCerts =
      trustedCerts.getTrustedCerts;
  static Future<void> Function(List<KretaCert>) setTrustedCerts =
      trustedCerts.setTrustedCerts;
}
