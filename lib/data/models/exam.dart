import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';

import 'description.dart';
import 'classGroup.dart';
import 'subject.dart';

class Exam {
  DateTime announcementDate;
  DateTime dateOfWriting;
  Description mode;
  int lessonNumber;
  String teacher;
  Subject subject;
  String theme;
  ClassGroup group;
  String uid;
  IconData icon;
  int databaseId;
  int userId;

  Exam({
    this.announcementDate,
    this.dateOfWriting,
    this.mode,
    this.lessonNumber,
    this.teacher,
    this.subject,
    this.theme,
    this.group,
    this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'announcementDate': announcementDate == null
          ? null
          : announcementDate.toUtc().toIso8601String(),
      'dateOfWriting': dateOfWriting == null
          ? null
          : dateOfWriting.toUtc().toIso8601String(),
      'mode': mode == null ? null : mode.toJson(),
      'lessonNumber': lessonNumber,
      'teacher': teacher,
      'subject': subject == null ? null : subject.uid,
      'theme': theme,
      'group': group == null ? null : group.toJson(),
      'uid': uid,
      'databaseId': databaseId,
      'userId': userId,
    };
  }

  Exam.fromSqlite(Map<String, dynamic> map) {
    announcementDate = map['announcementDate'] == null
        ? null
        : DateTime.parse(map['announcementDate']).toLocal();
    dateOfWriting = map['dateOfWriting'] == null
        ? null
        : DateTime.parse(map['dateOfWriting']).toLocal();
    mode = map['mode'] == null
        ? null
        : Description.fromJson(json.decode(map['mode']));
    lessonNumber = map['lessonNumber'];
    teacher = map['teacher'];
    subject = map['subject'] == null
        ? null
        : Subject.fromDatabaseId(
            map['subject'],
            "eval",
            teacher,
            dbId: this.databaseId,
            dbUid: this.uid,
            dbName: "Exams",
          );
    theme = map['theme'];
    group = map['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(map['group']));
    databaseId = map['databaseId'];
    userId = map['userId'];
    uid = map['uid'];
    icon = parseSubjectToIcon(subject: subject.fullName);
  }

  Exam.fromJson(Map<String, dynamic> json, Student userDetails) {
    userId = userDetails.userId;
    announcementDate = json['BejelentesDatuma'] != null
        ? DateTime.parse(json['BejelentesDatuma']).toLocal()
        : DateTime(2020);
    dateOfWriting = json['Datum'] != null
        ? DateTime.parse(json['Datum']).toLocal()
        : DateTime(2020);
    mode =
        json['Modja'] != null ? new Description.fromJson(json['Modja']) : null;
    lessonNumber = json['OrarendiOraOraszama'];
    teacher = json['RogzitoTanarNeve'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(
            json['Tantargy'],
            "eval",
            teacher,
          )
        : null;
    theme = json['Temaja'];
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
    icon = parseSubjectToIcon(subject: subject.fullName);
  }

  @override
  String toString() {
    return this.mode.name + ":" + this.theme;
  }
}
