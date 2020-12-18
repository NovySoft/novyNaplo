import 'description.dart';
import 'classGroup.dart';
import 'subject.dart';

class Absence {
  String justificationState;
  Description justificationType;
  int delayInMinutes;
  Description mode;
  String date;
  AbsenceLesson lesson;
  String teacher;
  Subject subject;
  Description type;
  ClassGroup group;
  DateTime createDate;
  String uid;
  int id;
  int databaseId;

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

  Absence.fromJson(Map<String, dynamic> json) {
    justificationState = json['IgazolasAllapota'];
    justificationType = json['IgazolasTipusa'] != null
        ? new Description.fromJson(json['IgazolasTipusa'])
        : null;
    delayInMinutes = json['KesesPercben'];
    createDate = DateTime.parse(json['KeszitesDatuma']).toLocal();
    mode = json['Mod'] != null ? new Description.fromJson(json['Mod']) : null;
    date = json['Datum'];
    lesson =
        json['Ora'] != null ? new AbsenceLesson.fromJson(json['Ora']) : null;
    teacher = json['RogzitoTanarNeve'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(json['Tantargy'])
        : null;
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
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
}
