import 'package:flutter/material.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'exam.dart';
import 'homework.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'classGroup.dart';
import 'package:novynaplo/global.dart' as globals;

class Lesson {
  Description state;
  List<String> examUidList;
  List<Exam> examList;
  String examUid;
  DateTime date;
  String deputyTeacher;
  bool isStudentHomeworkEnabled;
  DateTime startDate;
  String name;
  int lessonNumber;
  int lessonNumberYear;
  ClassGroup group;
  String teacherHwUid;
  Homework homework;
  bool isHWSolved;
  String teacher;
  Subject subject;
  Description presence;
  String theme;
  String classroom;
  Description type;
  String uid;
  DateTime endDate;
  int databaseId;
  int id;
  IconData icon;
  bool isSpecialDayEvent = false;

  Lesson({
    this.state,
    this.examUidList,
    this.examUid,
    this.deputyTeacher,
    this.isStudentHomeworkEnabled,
    this.name,
    this.lessonNumber,
    this.lessonNumberYear,
    this.group,
    this.teacherHwUid,
    this.isHWSolved,
    this.teacher,
    this.subject,
    this.presence,
    this.theme,
    this.classroom,
    this.type,
    this.uid,
  });

  Lesson.fromJson(Map<String, dynamic> json) {
    date = json['Datum'] != null
        ? DateTime.parse(json['Datum']).toLocal()
        : DateTime(2020);
    state = json['Allapot'] != null
        ? new Description.fromJson(json['Allapot'])
        : null;
    if (json['BejelentettSzamonkeresUids'] != null) {
      examUidList = [];
      examList = [];
      for (var v in json['BejelentettSzamonkeresUids']) {
        examUidList.add(v);
        examList.add(
          examsPage.allParsedExams.firstWhere(
            (item) => item.uid == v,
            orElse: () {
              return Exam();
            },
          ),
        );
      }
    }
    examUid = json['BejelentettSzamonkeresUid'];
    deputyTeacher = json['HelyettesTanarNeve'];
    isStudentHomeworkEnabled = json['IsTanuloHaziFeladatEnabled'];
    startDate = json['KezdetIdopont'] != null
        ? DateTime.parse(json['KezdetIdopont']).toLocal()
        : DateTime(2020);
    name = json['Nev'];
    lessonNumber = json['Oraszam'];
    lessonNumberYear = json['OraEvesSorszama'];
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    teacherHwUid = json['HaziFeladatUid'];
    if (teacherHwUid != null) {
      homework = homeworkPage.globalHomework.firstWhere(
        (element) => element.uid == teacherHwUid,
        orElse: () {
          return null;
        },
      );
    }
    if (homework == null && teacherHwUid != null) {
      RequestHandler.getHomeworkId(
        globals.currentUser,
        id: teacherHwUid,
      ).then((value) {
        homework = value;
      });
    }
    isHWSolved = json['IsHaziFeladatMegoldva'];
    teacher = json['TanarNeve'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(json['Tantargy'])
        : null;
    presence = json['TanuloJelenlet'] != null
        ? new Description.fromJson(json['TanuloJelenlet'])
        : null;
    theme = json['Tema'];
    classroom = json['TeremNeve'];
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    uid = json['Uid'];
    endDate = json['VegIdopont'] != null
        ? DateTime.parse(json['VegIdopont']).toLocal()
        : DateTime(2020);
    icon = parseSubjectToIcon(subject: subject == null ? "" : subject.name);
    if (subject == null) {
      isSpecialDayEvent = true;
    }
  }

  @override
  String toString() {
    return this.date.toLocal().toIso8601String();
  }
}
