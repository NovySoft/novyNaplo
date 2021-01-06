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
      'subject': subject == null ? null : subject.toJson(),
      'theme': theme,
      'group': group == null ? null : group.toJson(),
      'uid': uid,
      'databaseId': databaseId,
      'userId': userId,
    };
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
        ? new Subject.fromJson(json['Tantargy'])
        : null;
    theme = json['Temaja'];
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
    icon = parseSubjectToIcon(subject: subject.name);
  }

  @override
  String toString() {
    return this.mode.name + ":" + this.theme;
  }
}
