import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'utils.dart';
import 'package:novynaplo/helpers/subjectAssignHelper.dart';

var id = 0;

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
}

class Avarage {
  var subject, markCount, ownValue, classValue, diff;
}

Evals setEvals(var input) {
  Evals temp = new Evals();
  //Magatartas es Szorgalom
  if (input["Subject"] == null || input["Subject"] == "") {
    temp.subject = input["Jelleg"]["Nev"];
  } else {
    temp.subject = input["Subject"];
  }
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
  temp.id = id++;
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
}

Notices setNotices(var input) {
  Notices temp = new Notices();
  temp.title = capitalize(input["Title"]);
  temp.teacher = input["Teacher"];
  temp.content = input["Content"];
  temp.dateString = input["CreatingTime"];
  if (input["OsztalyCsoportUid"] == null) {
    temp.subject = null;
  } else {
    temp.subject = SubjectAssignHelper().assignSubject(
        globals.dJson, input["OsztalyCsoportUid"], input["Type"], input["Content"]);
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
  int groupID;
  List<dynamic> dogaIds; //Dynamic due to empty listes
  bool homeworkEnabled;
  DateTime date;
  DateTime startDate;
  DateTime endDate;
}

Lesson setLesson(input) {
  var temp = new Lesson();
  //INTs
  temp.id = input["LessonId"];
  temp.whichLesson = input["Count"];
  temp.homeWorkId = input["Homework"];
  temp.groupID = input["OsztalyCsoportId"];
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
  //Booleans
  temp.homeworkEnabled = input["IsTanuloHaziFeladatEnabled"];
  //Lists
  temp.dogaIds = input["BejelentettSzamonkeresIdList"];
  temp.dogaNames = []; //TODO EZT MEGCSINÁLNI
  return temp;
}

class CalculatorData {
  var value;
  var sum;
  int count;
  String name;
}

CalculatorData setCalcData(value, name, count, sum) {
  CalculatorData temp = new CalculatorData();
  temp.value = value;
  temp.count = count;
  temp.name = name;
  temp.sum = sum;
  return temp;
}
