import 'dart:convert';

import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/htmlLinkify.dart';

import 'classGroup.dart';
import 'subject.dart';

class Homework {
  List<Attachment> attachments;
  DateTime giveUpDate;
  DateTime dueDate;
  DateTime createDate;
  bool isTeacherHW;
  bool isStudentHomeworkEnabled;
  bool isSolved;
  String teacher;
  String content;
  Subject subject;
  ClassGroup group;
  String uid;
  int userId;
  int databaseId;

  Homework({
    this.attachments,
    this.giveUpDate,
    this.dueDate,
    this.createDate,
    this.isTeacherHW,
    this.isStudentHomeworkEnabled,
    this.isSolved,
    this.teacher,
    this.content,
    this.subject,
    this.group,
    this.uid,
  });

  String toString() {
    return dueDate.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'attachments': json.encode(attachments),
      'date': giveUpDate == null ? null : giveUpDate.toUtc().toIso8601String(),
      'dueDate': dueDate == null ? null : dueDate.toUtc().toIso8601String(),
      'createDate':
          createDate == null ? null : createDate.toUtc().toIso8601String(),
      'isTeacherHW': isTeacherHW ? 1 : 0,
      'isStudentHomeworkEnabled': isStudentHomeworkEnabled ? 1 : 0,
      'isSolved': isSolved ? 1 : 0,
      'teacher': teacher,
      'content': content,
      'subject': subject == null ? null : subject.uid,
      'group': group == null ? null : group.toJson(),
      'uid': uid,
      'userId': userId,
      'databaseId': databaseId,
    };
  }

  Homework.fromSqlite(Map<String, dynamic> map) {
    attachments = map['attachments'] == null
        ? null
        : Attachment.fromJsonList(map['attachments']);
    giveUpDate =
        map['date'] == null ? null : DateTime.parse(map['date']).toLocal();
    dueDate = map['dueDate'] == null
        ? null
        : DateTime.parse(map['dueDate']).toLocal();
    createDate = map['createDate'] == null
        ? null
        : DateTime.parse(map['createDate']).toLocal();
    isTeacherHW = map['isTeacherHW'] == 1 ? true : false;
    isStudentHomeworkEnabled =
        map['isStudentHomeworkEnabled'] == 1 ? true : false;
    isSolved = map['isSolved'] == 1 ? true : false;
    teacher = map['teacher'];
    content = map['content'];
    subject =
        map['subject'] == null ? null : Subject.fromDatabaseId(map['subject']);
    group = map['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(map['group']));
    uid = map['uid'];
    userId = map['userId'];
    databaseId = map['databaseId'];
  }

  Homework.fromJson(Map<String, dynamic> json, Student userDetails) {
    userId = userDetails.userId;
    if (json['Csatolmanyok'] != null) {
      attachments = <Attachment>[];
      json['Csatolmanyok'].forEach((v) {
        attachments.add(new Attachment.fromJson(v));
      });
    }
    giveUpDate = json['FeladasDatuma'] != null
        ? DateTime.parse(json['FeladasDatuma']).toLocal()
        : DateTime(2020);
    dueDate = json['HataridoDatuma'] != null
        ? DateTime.parse(json['HataridoDatuma']).toLocal()
        : DateTime(2020);
    createDate = json['RogzitesIdopontja'] != null
        ? DateTime.parse(json['RogzitesIdopontja']).toLocal()
        : DateTime(2020);
    isTeacherHW = json['IsTanarRogzitette'];
    isStudentHomeworkEnabled = json['IsTanuloHaziFeladatEnabled'];
    isSolved = json['IsMegoldva'];
    teacher = json['RogzitoTanarNeve'];
    content = htmlLinkify(json['Szoveg']);
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(
            json['Tantargy'],
            "eval",
            null,
          )
        : null;
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
  }
}

class Attachment {
  String uid;
  String name;
  String type;

  Attachment({this.uid, this.name, this.type});

  Attachment.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    name = json['Nev'];
    type = json['Tipus'];
  }

  String toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['Uid'] = uid;
    data['Nev'] = name;
    data['Tipus'] = type;
    return json.encode(data);
  }

  static List<Attachment> fromJsonList(dynamic inputJson) {
    List<Attachment> tempList = [];
    for (var n in json.decode(inputJson)) {
      tempList.add(Attachment.fromJson(json.decode(n)));
    }
    return tempList;
  }
}
