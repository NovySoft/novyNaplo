import 'dart:typed_data';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/homework_detail_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/screens/marks_detail_tab.dart';
import 'package:novynaplo/screens/homework_tab.dart' as homeworkTab;
import 'package:novynaplo/screens/notices_detail_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart' as noticeTab;
import 'package:novynaplo/screens/statistics_tab.dart';
import 'package:novynaplo/screens/timetable_tab.dart' as timetableTab;
import 'package:novynaplo/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/screens/exams_detail_tab.dart';

Int64List vibrationPattern;
var androidPlatformChannelSpecifics;
var iOSPlatformChannelSpecifics;
var platformChannelSpecifics;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> setupNotifications() async {
  vibrationPattern = new Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 500;
  vibrationPattern[3] = 1000;
  androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    'novynaplo01',
    'novynaplo',
    'Channel for sending novyNaplo notifications',
    importance: Importance.Max,
    priority: Priority.High,
    enableVibration: true,
    vibrationPattern: vibrationPattern,
    color: Color.fromARGB(255, 255, 165, 0),
    visibility: NotificationVisibility.Public,
    ledColor: Colors.orange,
    ledOnMs: 1000,
    ledOffMs: 1000,
    enableLights: true,
    playSound: true,
  );
  iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails.didNotificationLaunchApp) {
    selectNotification(notificationAppLaunchDetails.payload);
  }
  globals.notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  //print(notificationAppLaunchDetails.payload);
}

Future selectNotification(String payload) async {
  if (globals.globalContext == null) {
    print("NoContext");
    return;
  }
  if (ModalRoute.of(globals.globalContext).settings.name == "/") {
    print("MainRoute");
    return;
  }
  if (payload != null && payload != "teszt" && payload is String) {
    FirebaseAnalytics().logEvent(
      name: "SelectedNotification",
      parameters: {"payload": payload.split(" ")[0]},
    );
    print(payload.split(" ")[0] + ":" + payload.split(" ")[1]);
    globals.payloadId = int.parse(payload.split(" ")[1]);
    switch (payload.split(" ")[0]) {
      case "exam":
        int tempindex = examsPage.allParsedExams.indexWhere(
          (element) {
            return element.id == globals.payloadId;
          },
        );
        Exam tempExam = examsPage.allParsedExams.firstWhere(
          (element) {
            return element.id == globals.payloadId;
          },
          orElse: () {
            return new Exam();
          },
        );
        //Evals tempEval = allParsedByDate[0];
        if (tempExam.id != null)
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.push(
              globals.globalContext,
              MaterialPageRoute(
                builder: (context) => ExamsDetailTab(
                  exam: tempExam,
                  color: examsPage.colors.length == 0
                      ? Colors.green
                      : examsPage.colors[tempindex],
                ),
              ),
            );
          });
        globals.payloadId = -1;
        return;
        break;
      case "marks":
        int tempindex = marksTab.allParsedByDate.indexWhere(
          (element) {
            return element.id == globals.payloadId;
          },
        );
        Evals tempEval = marksTab.allParsedByDate.firstWhere(
          (element) {
            return element.id == globals.payloadId;
          },
          orElse: () {
            return new Evals();
          },
        );
        //Evals tempEval = allParsedByDate[0];
        if (tempEval.id != null)
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.push(
              globals.globalContext,
              MaterialPageRoute(
                builder: (context) => MarksDetailTab(
                  eval: tempEval,
                  color: marksTab.colors[tempindex],
                ),
              ),
            );
          });
        globals.payloadId = -1;
        return;
        break;
      case "hw":
        int tempindex = homeworkTab.globalHomework.indexWhere(
          (element) {
            return element.id == globals.payloadId;
          },
        );
        Homework tempHw = homeworkTab.globalHomework.firstWhere(
          (element) {
            return element.id == globals.payloadId;
          },
          orElse: () {
            return new Homework();
          },
        );
        if (homeworkTab.colors.length == 0 || homeworkTab.colors == [])
          homeworkTab.colors =
              getRandomColors(homeworkTab.globalHomework.length);
        //Evals tempEval = allParsedByDate[0];
        if (tempHw.id != null)
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.push(
              globals.globalContext,
              MaterialPageRoute(
                builder: (context) => HomeworkDetailTab(
                  hwInfo: tempHw,
                  color: homeworkTab.colors[tempindex],
                ),
              ),
            );
          });
        globals.payloadId = -1;
        return;
        break;
      case "notice":
        int tempindex = noticeTab.allParsedNotices.indexWhere(
          (element) {
            return element.id == globals.payloadId;
          },
        );
        Notices tempNotice = noticeTab.allParsedNotices.firstWhere(
          (element) {
            return element.id == globals.payloadId;
          },
          orElse: () {
            return new Notices();
          },
        );
        //Evals tempEval = allParsedByDate[0];
        if (tempNotice.id != null)
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.push(
              globals.globalContext,
              MaterialPageRoute(
                builder: (context) => NoticeDetailTab(
                  id: tempindex,
                  title: tempNotice.title,
                  teacher: tempNotice.teacher,
                  content: tempNotice.content,
                  date: tempNotice.dateString,
                  subject: tempNotice.subject,
                  color: noticeTab.colors[tempindex],
                ),
              ),
            );
          });
        globals.payloadId = -1;
        return;
        break;
      case "timetable":
        Navigator.of(globals.globalContext)
            .pushNamed(timetableTab.TimetableTab.tag);
        return;
        break;
      case "avarage":
        if (globals.showAllAvsInStats) {
          Navigator.of(globals.globalContext).pushNamed(StatisticsTab.tag);
        } else {
          Navigator.of(globals.globalContext).pushNamed(AvaragesTab.tag);
        }
        return;
        break;
    }
    Crashlytics.instance.log("Unkown payload: " + payload);
    showDialog<void>(
      context: globals.globalContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Értesítés'),
          content: Text("Ismeretlen payload:\n" + payload),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } else {
    print("TESZT");
    showTesztNotificationDialog();
  }
}

Future<void> showTesztNotificationDialog() async {
  showDialog<void>(
    context: globals.globalContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Státusz'),
        content: Text(
            "Egy teszt értesítést nyomtál meg...\nAmennyiben ez nem így történt jelentsd a hibát"),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
