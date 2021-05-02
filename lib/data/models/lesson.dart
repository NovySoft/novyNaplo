import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/exam.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/extensions.dart';
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
  int lessonNumberDay;
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
  int userId;
  IconData icon;
  bool isSpecialDayEvent = false;

  Lesson({
    this.state,
    this.examUidList,
    this.examUid,
    this.deputyTeacher,
    this.isStudentHomeworkEnabled,
    this.name,
    this.lessonNumberDay,
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

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'uid': uid,
      'state': state == null ? null : state.toJson(),
      'examUidList': json.encode(examUidList),
      'examUid': examUid,
      'date': date == null ? null : date.toUtc().toIso8601String(),
      'deputyTeacher': deputyTeacher,
      'isStudentHomeworkEnabled': isStudentHomeworkEnabled ? 1 : 0,
      'startDate':
          startDate == null ? null : startDate.toUtc().toIso8601String(),
      'name': name,
      'lessonNumberDay': lessonNumberDay,
      'lessonNumberYear': lessonNumberYear,
      'group': group == null ? null : group.toJson(),
      'teacherHwUid': teacherHwUid,
      'isHWSolved': isHWSolved ? 1 : 0,
      'teacher': teacher,
      'subject': subject == null ? null : subject.uid,
      'presence': presence == null ? null : presence.toJson(),
      'theme': theme,
      'classroom': classroom,
      'type': type == null ? null : type.toJson(),
      'endDate': endDate == null ? null : endDate.toUtc().toIso8601String(),
      'isSpecialDayEvent': isSpecialDayEvent ? 1 : 0,
      'userId': userId,
    };
  }

  Lesson.fromSqlite(Map<String, dynamic> map) {
    state = map['state'] == null
        ? null
        : Description.fromJson(json.decode(map['state']));
    var tempExamUidList = json.decode(map['examUidList']);
    examUidList =
        tempExamUidList == null ? null : tempExamUidList.cast<String>();
    if (examUidList != null) {
      examList = [];
      for (var v in examUidList) {
        examList.add(
          examsPage.allParsedExams.firstWhere(
            (item) => item.uid == v,
            orElse: () {
              Exam temp;
              getExamById(
                v,
                Student(userId: map['userId']),
              ).then((value) {
                temp = value;
              });
              if (temp == null) {
                return temp;
              } else {
                //Sadly there is no way to fetch exam by id in kreta
                return Exam();
              }
            },
          ),
        );
      }
    }
    examUid = map['examUid'];
    date = map['date'] == null ? null : DateTime.parse(map['date']).toLocal();
    deputyTeacher = map['deputyTeacher'];
    isStudentHomeworkEnabled =
        map['isStudentHomeworkEnabled'] == 1 ? true : false;
    startDate = map['startDate'] == null
        ? null
        : DateTime.parse(map['startDate']).toLocal();
    name = map['name'];
    lessonNumberDay = map['lessonNumberDay'];
    lessonNumberYear = map['lessonNumberYear'];
    group = map['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(map['group']));
    teacherHwUid = map['teacherHwUid'];
    if (teacherHwUid != null) {
      homework = homeworkPage.globalHomework.firstWhere(
        (element) => element.uid == teacherHwUid,
        orElse: () {
          Homework homework = Homework();
          RequestHandler.getHomeworkId(
            globals.currentUser,
            id: teacherHwUid,
            isStandAloneCall: true,
          ).then((value) {
            homework = value;
          });
          return homework;
        },
      );
    }
    isHWSolved = map['teacherHwUid'] == 1 ? true : false;
    teacher = map['teacher'];
    subject =
        map['subject'] == null ? null : Subject.fromDatabaseId(map['subject']);
    presence = map['presence'] == null
        ? null
        : Description.fromJson(json.decode(map['presence']));
    theme = map['theme'];
    classroom = map['classroom'];
    type = map['type'] == null
        ? null
        : Description.fromJson(json.decode(map['type']));
    uid = map['uid'];
    endDate = map['endDate'] == null
        ? null
        : DateTime.parse(map['endDate']).toLocal();
    databaseId = map['databaseId'];
    userId = map['userId'];
    icon = parseSubjectToIcon(
      subject: subject == null ? "" : subject.fullName,
    );
    isSpecialDayEvent = map['isSpecialDayEvent'] == 1 ? true : false;
  }

  Lesson.fromJson(Map<String, dynamic> json, Student userDetails) {
    userId = userDetails.userId;
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
              Exam temp;
              getExamById(v, userDetails).then((value) {
                temp = value;
              });
              if (temp == null) {
                return temp;
              } else {
                return Exam();
              }
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
    lessonNumberDay = json['Oraszam'];
    lessonNumberYear = json['OraEvesSorszama'];
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    teacherHwUid = json['HaziFeladatUid'];
    if (teacherHwUid != null) {
      homework = homeworkPage.globalHomework.firstWhere(
        (element) => element.uid == teacherHwUid,
        orElse: () {
          Homework temp;
          RequestHandler.getHomeworkId(
            globals.currentUser,
            id: teacherHwUid,
            isStandAloneCall: true,
          ).then((value) {
            temp = value;
          });
          return temp;
        },
      );
    }
    isHWSolved = json['IsHaziFeladatMegoldva'];
    teacher = json['TanarNeve'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(
            json['Tantargy'],
            "timetable",
            teacher,
          )
        : null;
    presence = json['TanuloJelenlet'] != null
        ? new Description.fromJson(json['TanuloJelenlet'])
        : null;
    theme = json['Tema'];
    classroom = json['TeremNeve'];
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    try {
      uid = json['Uid'].split(',')[0];
    } catch (e) {
      uid = json['Uid'];
    }
    if (subject != null) {
      //A tantárgy nem változik, de ha lehet a uid-t hagyjuk el
      if (subject.category.uid.split(",").length <= 1) {
        uid += subject.category.uid;
      } else {
        uid += subject.category.uid.split(",")[1];
      }
    }
    if (date != null) {
      //És a dátum (nap,hónap,év) se kéne, hogy változzon
      uid += date.toDayOnlyString();
    }
    endDate = json['VegIdopont'] != null
        ? DateTime.parse(json['VegIdopont']).toLocal()
        : DateTime(2020);
    icon = parseSubjectToIcon(
      subject: subject == null ? "" : subject.fullName,
    );
    if (subject == null) {
      isSpecialDayEvent = true;
      uid += "SpecialDayEvent";
    }

    //Someone please explain to kréta what UNIQUE identifier means, because they have MULTIPLE SAME UIDS
  }

  @override
  String toString() {
    return this.date.toLocal().toIso8601String();
  }
}
