import 'package:flutter/cupertino.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';

import 'description.dart';
import 'classGroup.dart';
import 'subject.dart';

class Exam {
  DateTime announcementDate;
  DateTime date;
  Description mode;
  int lessonNumber;
  String teacher;
  Subject subject;
  String theme;
  ClassGroup group;
  String uid;
  int id;
  IconData icon;

  Exam(
      {this.announcementDate,
      this.date,
      this.mode,
      this.lessonNumber,
      this.teacher,
      this.subject,
      this.theme,
      this.group,
      this.uid});

  Exam.fromJson(Map<String, dynamic> json) {
    announcementDate = json['BejelentesDatuma'] != null
        ? DateTime.parse(json['BejelentesDatuma']).toLocal()
        : DateTime(2020);
    date = json['Datum'] != null
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
    id = int.parse(uid);
    icon = parseSubjectToIcon(subject: subject.name);
  }

  @override
  String toString() {
    return this.mode.name + ":" + this.theme;
  }
}
