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
  String subject;
  Description type;
  String uid;
  int id;

  Notice(
      {this.title,
      this.teacher,
      this.group,
      this.content,
      this.type,
      this.uid});

  Notice.fromJson(Map<String, dynamic> json) {
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
        : null;
    content = json['Tartalom'];
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    uid = json['Uid'];
  }
}
