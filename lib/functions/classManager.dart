import 'dart:convert';

import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/networkHelper.dart';
import 'utils.dart';
import 'package:novynaplo/helpers/subjectAssignHelper.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/utils.dart';

class Evals {
  var formName,
      form,
      id,
      value,
      numberValue,
      teacher,
      type,
      subject,
      theme,
      mode,
      weight;
  String dateString;
  String createDateString;
  DateTime createDate;
  DateTime date;
  IconData icon;
  int databaseId;

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'formName': formName,
      'form': form,
      'value': value,
      'numberValue': numberValue,
      'teacher': teacher,
      'type': type,
      'subject': subject,
      'theme': theme,
      'mode': mode,
      'weight': weight,
      'dateString': dateString,
      'createDateString': createDateString,
    };
  }
}

class Avarage {
  var subject, ownValue, classValue, diff;
  int databaseId;

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'subject': subject,
      'ownValue': ownValue,
      'classValue': classValue,
      'diff': diff
    };
  }
}

Evals setEvals(var input) {
  Evals temp = new Evals();
  //Magatartas es Szorgalom
  if (input["Subject"] == null || input["Subject"] == "") {
    temp.subject = input["Jelleg"]["Nev"];
  } else {
    temp.subject = input["Subject"];
  }
  //Icon
  temp.icon = parseSubjectToIcon(subject: temp.subject);
  //Magatartas es Szorgalom integer
  if (input["NumberValue"] == 0 && input["Form"] != "Percent") {
    switch (input["Value"]) {
      case "Rossz":
        temp.numberValue = 2;
        break;
      case "Változó":
        temp.numberValue = 3;
        break;
      case "Jó":
        temp.numberValue = 4;
        break;
      case "Példás":
        temp.numberValue = 5;
        break;
      default:
        temp.numberValue = 0;
        break;
    }
  } else {
    temp.numberValue = input["NumberValue"];
  }
  //Ertekeles temaja
  if (input["Theme"] == null || input["Theme"] == "") {
    if (input["Mode"] != null) {
      temp.theme = input["Mode"];
    } else {
      //There is no other option than typeName
      temp.theme = input["TypeName"];
    }
  } else {
    temp.theme = input["Theme"];
  }
  //Ertekeles modja
  if (input["Mode"] == null || input["Mode"] == "") {
    temp.mode = input["TypeName"];
  } else {
    temp.mode = input["Mode"];
  }
  //Ertekeles sulya
  if (input["Weight"] == null ||
      input["Weight"] == "" ||
      input["Weight"] == "-") {
    if (input["Form"] != "Percent") {
      temp.weight = "100%";
    } else {
      temp.weight = "0%";
    }
    //feltehetoleg 100%osan beleszámít, pl a szorgalomnal is igy van
  } else {
    temp.weight = input["Weight"];
  }
  temp.id = input[
      "EvaluationId"]; //We see no use for this, because we use databaseIDs most of the times
  temp.value = input["Value"];
  temp.formName = input["FormName"];
  temp.form = input["Form"];
  temp.teacher = input["Teacher"];
  temp.type = input["Type"];
  temp.dateString = input["Date"];
  temp.createDateString = input["CreatingTime"];
  temp.createDate = DateTime.parse(input["CreatingTime"]);
  temp.date = DateTime.parse(input["Date"]);
  return temp;
}

Avarage setAvarage(var subject, ownValue, classValue, diff) {
  Avarage temp = new Avarage();
  temp.subject = capitalize(subject);
  temp.ownValue = ownValue;
  temp.classValue = classValue;
  temp.diff = diff;
  return temp;
}

class Notices {
  var title, content, teacher, dateString, subject;
  DateTime date;
  int databaseId;
  int id;

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
}

Notices setNotices(var input) {
  Notices temp = new Notices();
  temp.title = capitalize(input["Title"]);
  temp.teacher = input["Teacher"];
  temp.content = input["Content"];
  temp.dateString = input["CreatingTime"];
  temp.date = DateTime.parse(input["CreatingTime"]);
  temp.id = input["NoteId"];
  if (input["OsztalyCsoportUid"] == null) {
    temp.subject = null;
  } else {
    temp.subject = SubjectAssignHelper().assignSubject(globals.dJson,
        input["OsztalyCsoportUid"], input["Type"], input["Content"]);
  }
  return temp;
}

class School {
  int id;
  String name;
  String code;
  String url;
  String city;
}

class Lesson {
  int databaseId;
  String subject;
  String name;
  String groupName;
  String classroom;
  String theme;
  String teacher;
  String deputyTeacherName;
  List<dynamic> dogaNames; //Dynamic due to empty listes
  int whichLesson;
  int id;
  int homeWorkId;
  int teacherHomeworkId;
  int groupID;
  List<dynamic> dogaIds; //Dynamic due to empty listes
  bool homeworkEnabled;
  DateTime date;
  String dateString;
  DateTime startDate;
  String startDateString;
  DateTime endDate;
  String endDateString;
  Homework homework = new Homework();

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'theme': theme,
      'subject': subject,
      'teacher': teacher,
      'name': name,
      'groupName': groupName,
      'classroom': classroom,
      'deputyTeacherName': deputyTeacherName,
      'dogaNames': json.encode(dogaNames),
      'whichLesson': whichLesson,
      'homeWorkId': homeWorkId,
      'teacherHomeworkId': teacherHomeworkId,
      'groupID': groupID,
      'dogaIds': json.encode(dogaIds),
      'homeworkEnabled': homeworkEnabled,
      'date': dateString,
      'startDate': startDateString,
      'endDate': endDateString,
    };
  }
}

Future<Lesson> setLesson(var input, token, code) async {
  var temp = new Lesson();
  //INTs
  temp.id = input["LessonId"];
  temp.whichLesson = input["Count"];
  temp.homeWorkId = input["Homework"];
  temp.groupID = input["OsztalyCsoportId"];
  temp.teacherHomeworkId = input["TeacherHomeworkId"];
  //Strings
  temp.groupName = input["ClassGroup"];
  temp.subject = capitalize(input["Subject"]);
  temp.name = capitalize(input["Nev"]);
  if (input["ClassRoom"].toString().startsWith("I")) {
    temp.classroom = input["ClassRoom"];
  } else {
    temp.classroom = capitalize(input["ClassRoom"]);
  }
  temp.theme = input["Theme"];
  temp.teacher = input["Teacher"];
  temp.deputyTeacherName = input["DeputyTeacher"];
  //DateTimes
  temp.startDate = DateTime.parse(input["StartTime"]);
  temp.endDate = DateTime.parse(input["EndTime"]);
  temp.date = DateTime.parse(input["Date"]);
  //Datetime sttring
  temp.startDateString = input["StartTime"];
  temp.endDateString = input["EndTime"];
  temp.dateString = input["Date"];
  //Booleans
  temp.homeworkEnabled = input["IsTanuloHaziFeladatEnabled"];
  //Lists
  temp.dogaIds = input["BejelentettSzamonkeresIdList"];
  temp.dogaNames = []; //TODO EZT MEGCSINÁLNI
  if (temp.teacherHomeworkId != null) {
    temp.homework =
        await setTeacherHomework(temp.teacherHomeworkId, token, code);
  } else {
    temp.homework = new Homework();
  }
  return temp;
}

class CalculatorData {
  var value;
  num sum;
  num count;
  String name;
}

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
  IconData icon;
  int databaseId;

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

Homework setHomework(var decoded) {
  Homework temp = new Homework();
  temp.classGroupId = int.parse(decoded["OsztalyCsoportUid"]);
  temp.id = decoded["Id"];
  temp.subject = capitalize(decoded["Tantargy"]);
  temp.icon = parseSubjectToIcon(subject: temp.subject);
  temp.teacher = decoded["Rogzito"];
  temp.content = decoded["Szoveg"];
  temp.givenUpString = decoded["FeladasDatuma"];
  temp.givenUp = DateTime.parse(decoded["FeladasDatuma"]);
  temp.dueDateString = decoded["Hatarido"];
  temp.dueDate = DateTime.parse(decoded["Hatarido"]);
  return temp;
}
