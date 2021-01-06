import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/subject.dart';

import 'description.dart';
import 'classGroup.dart';

class Notice {
  String title;
  DateTime date;
  DateTime createDate;
  String teacher;
  DateTime seenDate;
  ClassGroup group;
  String content;
  Subject subject;
  Description type;
  String uid;
  int databaseId;
  int userId;

  Notice(
      {this.title,
      this.teacher,
      this.group,
      this.content,
      this.type,
      this.uid});

  Notice.fromJson(Map<String, dynamic> json, Student userDetails) {
    userId = userDetails.userId;
    title = json['Cim'];
    date =
        json['Datum'] != null ? DateTime.parse(json['Datum']).toLocal() : null;
    createDate = json['KeszitesDatuma'] != null
        ? DateTime.parse(json['KeszitesDatuma']).toLocal()
        : null;
    teacher = json['KeszitoTanarNeve'];
    seenDate = json['LattamozasDatuma'] != null
        ? DateTime.parse(json['LattamozasDatuma']).toLocal()
        : null;
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    content = json['Tartalom'];
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    uid = json['Uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date == null ? null : date.toUtc().toIso8601String(),
      'createDate':
          createDate == null ? null : createDate.toUtc().toIso8601String(),
      'teacher': teacher,
      'seenDate': seenDate == null ? null : seenDate.toUtc().toIso8601String(),
      'group': group == null ? null : group.toJson(),
      'content': content,
      'subject': subject == null ? null : subject.toJson(),
      'type': type == null ? null : type.toJson(),
      'uid': uid,
      'databaseId': databaseId,
      'userId': userId,
    };
  }
}
