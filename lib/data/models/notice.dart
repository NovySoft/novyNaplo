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
    date = json['Datum'] != null
        ? DateTime.parse(json['Datum']).toLocal()
        : DateTime(2020);
    createDate = json['KeszitesDatuma'] != null
        ? DateTime.parse(json['KeszitesDatuma']).toLocal()
        : DateTime(2020);
    teacher = json['KeszitoTanarNeve'];
    seenDate = json['LattamozasDatuma'] != null
        ? DateTime.parse(json['LattamozasDatuma']).toLocal()
        : DateTime(2020);
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : ClassGroup(uid: 'noGroup', name: 'No group was given');
    content = json['Tartalom'];
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    uid = json['Uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'createDate': createDate.toIso8601String(),
      'teacher': teacher,
      'seenDate': seenDate.toIso8601String(),
      'group': group.toJson(),
      'content': content,
      //FIXME: Subject value
      //'subject': subject.toJson(),
      'type': type.toJson(),
      'uid': uid,
      'databaseId': databaseId,
      'userId': userId,
    };
  }
}
