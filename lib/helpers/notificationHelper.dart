import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/screens/homework_tab.dart' as homeworkTab;
import 'package:novynaplo/screens/notices_tab.dart' as noticeTab;
import 'package:novynaplo/screens/timetable_tab.dart' as timetableTab;

//TODO group notifications
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
  globals.notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  //print(notificationAppLaunchDetails.payload);
}

Future selectNotification(String payload) async {
  if (ModalRoute.of(globals.globalContext).settings.name == "/") return;
  if (payload != null && payload != "teszt" && payload is String) {
    globals.payloadId = int.parse(payload.split(" ")[1]);
    switch (payload.split(" ")[0]) {
      case "marks":
        Navigator.of(globals.globalContext).pushNamed(marksTab.MarksTab.tag);
        return;
        break;
      case "hw":
        Navigator.of(globals.globalContext)
            .pushNamed(homeworkTab.HomeworkTab.tag);
        return;
        break;
      case "notice":
        Navigator.of(globals.globalContext)
            .pushNamed(noticeTab.NoticesTab.tag);
        return;
        break;
      case "timetable":
        Navigator.of(globals.globalContext)
            .pushNamed(timetableTab.TimetableTab.tag);
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
}
