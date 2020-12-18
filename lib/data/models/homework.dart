import 'classGroup.dart';
import 'subject.dart';

class Homework {
  List<Attachment> attachments;
  DateTime date;
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
  int id;

  Homework(
      {this.attachments,
      this.date,
      this.dueDate,
      this.createDate,
      this.isTeacherHW,
      this.isStudentHomeworkEnabled,
      this.isSolved,
      this.teacher,
      this.content,
      this.subject,
      this.group,
      this.uid});

  Homework.fromJson(Map<String, dynamic> json) {
    if (json['Csatolmanyok'] != null) {
      attachments = new List<Attachment>();
      json['Csatolmanyok'].forEach((v) {
        attachments.add(new Attachment.fromJson(v));
      });
    }
    date = json['FeladasDatuma'] != null
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
    content = json['Szoveg'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(json['Tantargy'])
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
}
