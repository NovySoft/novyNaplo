import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'homework.dart';

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

  Lesson.fromJson(Map<String, dynamic> json) {
    //INTs
    id = json["LessonId"];
    whichLesson = json["Count"];
    homeWorkId = json["Homework"];
    groupID = json["OsztalyCsoportId"];
    teacherHomeworkId = json["TeacherHomeworkId"];
    //Strings
    groupName = json["ClassGroup"];
    subject = capitalize(json["Subject"]);
    name = capitalize(json["Nev"]);
    if (json["ClassRoom"].toString().startsWith("I")) {
      classroom = json["ClassRoom"];
    } else {
      classroom = capitalize(json["ClassRoom"]);
    }
    theme = json["Theme"];
    teacher = json["Teacher"];
    deputyTeacherName = json["DeputyTeacher"];
    //DateTimes
    startDate = DateTime.parse(json["StartTime"]);
    endDate = DateTime.parse(json["EndTime"]);
    date = DateTime.parse(json["Date"]);
    //Datetime sttring
    startDateString = json["StartTime"];
    endDateString = json["EndTime"];
    dateString = json["Date"];
    //Booleans
    homeworkEnabled = json["IsTanuloHaziFeladatEnabled"];
    //Lists
    dogaIds = json["BejelentettSzamonkeresIdList"];
    dogaNames = []; //TODO EZT MEGCSINÁLNI
    //Icon
    icon = parseSubjectToIcon(subject: subject);
    //Homework
    if (teacherHomeworkId != null) {
      //FIXME FIX
      teacherHomework = new Homework();
      /*teacherHomework = await NetworkHelper()
          .getTeacherHomework(teacherHomeworkId, token, code);*/
    } else {
      teacherHomework = new Homework();
    }
  }

  @override
  String toString() {
    return this.name + " " + this.theme;
  }
}
