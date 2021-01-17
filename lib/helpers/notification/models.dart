import 'package:flutter/material.dart';

///Store a single notificaiton's data
class NotificationData {
  String title;
  String subtitle;
  String uid;
  int userId;
  //New or changed, doesn't matter on averages and timetable
  String notificationType = "New";

  NotificationData({
    @required this.title,
    @required this.subtitle,
    @required this.uid,
    @required this.userId,
    @required this.notificationType,
  });
}

///Stores the notifications that are not yet dispatched
class ToBeDispatchedNotifications {
  List<NotificationData> marks = [];
  List<NotificationData> homeworks = [];
  List<NotificationData> notices = [];
  List<NotificationData> timetables = [];
  List<NotificationData> exams = [];
  List<NotificationData> averages = [];
  List<NotificationData> events = [];
  List<NotificationData> absences = [];

  ToBeDispatchedNotifications();
}

///Whether to collapse a specific notification type
class WhichToCollapse {
  bool marks = false;
  bool homeworks = false;
  bool notices = false;
  bool lessons = false;
  bool exams = false;
  bool averages = false;
  bool events = false;
  bool absences = false;

  void all(bool input) {
    this.marks = input;
    this.homeworks = input;
    this.notices = input;
    this.lessons = input;
    this.exams = input;
    this.averages = input;
    this.events = input;
    this.absences = input;
  }

  @override
  String toString() {
    return """
    marks = $marks
    homeworks = $homeworks
    notices = $notices
    timetables = $lessons
    exams = $exams
    averages = $averages
    events = $events
    absences = $absences
    """;
  }

  WhichToCollapse();
}
