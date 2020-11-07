import 'package:novynaplo/helpers/misc/capitalize.dart';

class Homework {
  int id;
  int classGroupId;
  String subject;
  String teacher;
  String content;
  String givenUpString;
  String dueDateString;
  DateTime givenUp;
  DateTime dueDate;
  int databaseId;
  Homework();

  Homework.fromJson(Map<String, dynamic> json) {
    classGroupId = int.parse(json["OsztalyCsoportUid"]);
    id = json["Id"];
    subject = capitalize(json["Tantargy"]);
    teacher = json["Rogzito"];
    content = json["Szoveg"];
    givenUpString = json["RogzitesIdopontja"];
    givenUp = DateTime.parse(json["RogzitesIdopontja"]);
    dueDateString = json["Hatarido"];
    dueDate = DateTime.parse(json["Hatarido"]);
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'classGroupId': classGroupId,
      'subject': subject,
      'teacher': teacher,
      'content': content,
      'givenUpString': givenUpString,
      'dueDateString': dueDateString,
    };
  }
}
