import 'package:flutter/material.dart';

///Store a single notificaiton's data
class NotificationData {
  String title;
  String subtitle;
  String uid;
  String payload;
  int userId;
  //I it edited doesn't matter on averages and timetable
  bool isEdited = false;

  @override
  String toString() {
    return title;
  }

  NotificationData({
    @required this.title,
    @required this.subtitle,
    @required this.uid,
    @required this.userId,
    @required this.isEdited,
    @required this.payload,
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

  int getAllLength() {
    return marks.length +
        homeworks.length +
        notices.length +
        timetables.length +
        exams.length +
        averages.length +
        events.length +
        absences.length;
  }

  List<NotificationData> listOfAllNotifications() => [
        ...marks,
        ...homeworks,
        ...notices,
        ...timetables,
        ...exams,
        ...averages,
        ...events,
        ...absences
      ];

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

//This is the same as above, but it uses matrixes, to store the notifications, by userId
class ToBeDispatchedNotificationsMatrix {
  List<List<NotificationData>> marks = [];
  List<List<NotificationData>> homeworks = [];
  List<List<NotificationData>> notices = [];
  List<List<NotificationData>> timetables = [];
  List<List<NotificationData>> exams = [];
  List<List<NotificationData>> averages = [];
  List<List<NotificationData>> events = [];
  List<List<NotificationData>> absences = [];

  ToBeDispatchedNotificationsMatrix();
}
