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
