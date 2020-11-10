import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'homework.dart';
import 'package:novynaplo/global.dart' as globals;

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
  IconData icon;
  Homework teacherHomework = new Homework();
  List<Homework> studentsHomework = [];
  Lesson();

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
      'homeworkEnabled': homeworkEnabled ? 1 : 0,
      'date': dateString,
      'startDate': startDateString,
      'endDate': endDateString,
      //'studentsHomework': json.encode(studentsHomework),
    };
  }

  //This class is an exceptional one, because we wanted to run a async function in the constructor
  static Future<Lesson> fromJson(Map<String, dynamic> json) async {
    Lesson temp = new Lesson();
    //INTs
    temp.id = json["LessonId"];
    temp.whichLesson = json["Count"];
    temp.homeWorkId = json["Homework"];
    temp.groupID = json["OsztalyCsoportId"];
    temp.teacherHomeworkId = json["TeacherHomeworkId"];
    //Strings
    temp.groupName = json["ClassGroup"];
    temp.subject = capitalize(json["Subject"]);
    temp.name = capitalize(json["Nev"]);
    if (json["ClassRoom"].toString().startsWith("I")) {
      temp.classroom = json["ClassRoom"];
    } else {
      temp.classroom = capitalize(json["ClassRoom"]);
    }
    temp.theme = json["Theme"];
    temp.teacher = json["Teacher"];
    temp.deputyTeacherName = json["DeputyTeacher"];
    //DateTimes
    temp.startDate = DateTime.parse(json["StartTime"]);
    temp.endDate = DateTime.parse(json["EndTime"]);
    temp.date = DateTime.parse(json["Date"]);
    //Datetime sttring
    temp.startDateString = json["StartTime"];
    temp.endDateString = json["EndTime"];
    temp.dateString = json["Date"];
    //Booleans
    temp.homeworkEnabled = json["IsTanuloHaziFeladatEnabled"];
    //Lists
    temp.dogaIds = json["BejelentettSzamonkeresIdList"];
    temp.dogaNames = []; //TODO EZT MEGCSINÁLNI
    //Icon
    temp.icon = parseSubjectToIcon(subject: temp.subject);
    //Homework
    if (temp.teacherHomeworkId != null) {
      /*temp.teacherHomework = await NetworkHelper().getTeacherHomework(
        temp.teacherHomeworkId,
        globals.userDetails.token,
        globals.userDetails.school,
      );*/
    } else {
      temp.teacherHomework = new Homework();
    }
    return temp;
  }

  @override
  String toString() {
    return this.name + " " + this.theme;
  }
}
