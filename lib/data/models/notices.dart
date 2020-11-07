import 'package:novynaplo/helpers/functions/capitalize.dart';
import 'package:novynaplo/helpers/subjectAssignHelper.dart';
import 'package:novynaplo/global.dart' as globals;

class Notices {
  var title, content, teacher, dateString, subject;
  DateTime date;
  int databaseId;
  int id;
  Notices();

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'title': title,
      'content': content,
      'teacher': teacher,
      'dateString': dateString,
      'subject': subject,
    };
  }

  Notices.fromJson(Map<String, dynamic> json) {
    title = capitalize(json["Title"]);
    teacher = json["Teacher"];
    content = json["Content"];
    dateString = json["CreatingTime"];
    date = DateTime.parse(json["CreatingTime"]);
    id = json["NoteId"];
    if (json["OsztalyCsoportUid"] == null) {
      subject = null;
    } else {
      subject = SubjectAssignHelper.assignSubject(globals.dJson,
          json["OsztalyCsoportUid"], json["Type"], json["Content"]);
    }
  }
}
