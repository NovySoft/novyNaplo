import 'dart:convert';
import 'package:novynaplo/data/models/student.dart';

import 'description.dart';
import 'classGroup.dart';
import 'subject.dart';

class Absence {
  String justificationState;
  Description justificationType;
  int delayInMinutes;
  Description mode;
  DateTime date;
  AbsenceLesson lesson;
  String teacher;
  Subject subject;
  Description type;
  ClassGroup group;
  DateTime createDate;
  String uid;
  int databaseId;
  int userId;

  Absence(
      {this.justificationState,
      this.justificationType,
      this.delayInMinutes,
      this.mode,
      this.date,
      this.lesson,
      this.teacher,
      this.subject,
      this.type,
      this.group,
      this.uid});

  Absence.fromSqlite(Map<String, dynamic> map) {
    databaseId = map['databaseId'];
    justificationState = map['justificationState'];
    justificationType = map['justificationType'] == null
        ? null
        : Description.fromJson(json.decode(map['justificationType']));
    delayInMinutes = map['delayInMinutes'];
    uid = map['uid'];
    mode = map['mode'] == null
        ? null
        : Description.fromJson(json.decode(map['mode']));
    date = map['date'] == null ? null : DateTime.parse(map['date']).toLocal();
    lesson = map['lesson'] == null
        ? null
        : AbsenceLesson.fromJson(json.decode(map['lesson']));
    teacher = map['teacher'];
    subject = map['subject'] == null
        ? null
        : Subject.fromDatabaseId(
            map['subject'],
            null,
            dbId: this.databaseId,
            dbUid: this.uid,
            dbName: "Absences",
          );
    type = map['type'] == null
        ? null
        : Description.fromJson(json.decode(map['type']));
    group = map['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(map['group']));
    createDate = map['createDate'] == null
        ? null
        : DateTime.parse(map['createDate']).toLocal();
    userId = map['userId'];
  }

  Absence.fromJson(Map<String, dynamic> json, Student userDetails) {
    userId = userDetails.userId;
    justificationState = json['IgazolasAllapota'];
    justificationType = json['IgazolasTipusa'] != null
        ? new Description.fromJson(json['IgazolasTipusa'])
        : null;
    delayInMinutes = json['KesesPercben'];
    createDate = DateTime.parse(json['KeszitesDatuma']).toLocal();
    mode = json['Mod'] != null ? new Description.fromJson(json['Mod']) : null;
    date =
        json['Datum'] != null ? DateTime.parse(json['Datum']).toLocal() : null;
    lesson =
        json['Ora'] != null ? new AbsenceLesson.fromJson(json['Ora']) : null;
    teacher = json['RogzitoTanarNeve'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(
            json['Tantargy'],
            null,
          )
        : null;
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'userId': userId,
      'uid': uid,
      'teacher': teacher,
      'subject': subject == null ? null : subject.uid,
      'justificationState': justificationState,
      'justificationType':
          justificationType == null ? null : justificationType.toJson(),
      'delayInMinutes': delayInMinutes,
      'mode': mode == null ? null : mode.toJson(),
      'date': date == null ? null : date.toUtc().toIso8601String(),
      'lesson': lesson == null ? null : lesson.toJson(),
      'type': type == null ? null : type.toJson(),
      'group': group == null ? null : group.toJson(),
      'createDate':
          createDate == null ? null : createDate.toUtc().toIso8601String(),
    };
  }
}

class AbsenceLesson {
  DateTime startDate;
  DateTime endDate;
  int lessonNumber;

  AbsenceLesson({this.startDate, this.endDate, this.lessonNumber});

  AbsenceLesson.fromJson(Map<String, dynamic> json) {
    startDate = DateTime.parse(json['KezdoDatum']).toLocal();
    endDate = DateTime.parse(json['VegDatum']).toLocal();
    lessonNumber = json['Oraszam'];
  }

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['KezdoDatum'] = this.startDate == null
        ? null
        : this.startDate.toUtc().toIso8601String();
    data['VegDatum'] =
        this.endDate == null ? null : this.endDate.toUtc().toIso8601String();
    data['Oraszam'] = this.lessonNumber;
    return json.encode(data);
  }
}
