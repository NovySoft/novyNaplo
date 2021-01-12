import 'dart:typed_data';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/waitWhile.dart';
import 'package:novynaplo/main.dart';
import 'package:novynaplo/ui/screens/absences_tab.dart';
import 'package:novynaplo/ui/screens/events_tab.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart';

class NotificationHelper {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static AndroidNotificationDetails androidPlatformChannelSpecifics;
  static IOSNotificationDetails iOSPlatformChannelSpecifics;
  static NotificationDetails platformChannelSpecifics;
  static Int64List vibrationPattern;

  static Future<void> setupNotifications() async {
    FirebaseCrashlytics.instance.log("setupNotifications");
    vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 300;
    vibrationPattern[1] = 100;
    vibrationPattern[2] = 300;
    vibrationPattern[3] = 300;
    androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'novynaplo',
      'novynaplo',
      'Channel for sending novyNaplo main notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      color: Color.fromARGB(255, 255, 165, 0),
      visibility: NotificationVisibility.private,
      ledColor: Colors.orange,
      ledOnMs: 1000,
      ledOffMs: 1000,
      enableLights: true,
      playSound: true,
    );
    iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    NotificationAppLaunchDetails notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails.didNotificationLaunchApp) {
      selectNotification(notificationAppLaunchDetails.payload);
    }
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  static Future<void> selectNotification(String payload) async {
    try {
      if (payload == null) {
        return;
      }

      FirebaseCrashlytics.instance
          .log("selectNotification received (payload $payload)");

      globals.notifPayload = payload.toString();
      String payloadPrefix = payload.split(" ")[0];
      String content = payload.split(" ").sublist(1).join();
      //*If content is missing it means, that the user clicked on a "combined" notification and we can just navigate to the according page
      //FIXME: When multiuser support is added we also have to change users. And also make an option to show the data without changing users
      if (content == null || content == "") {
        switch (payloadPrefix) {
          case "marks":
            globalWaitAndPushNamed(MarksTab.tag);
            break;
          case "hw":
            globalWaitAndPushNamed(HomeworkTab.tag);
            break;
          case "notice":
            globalWaitAndPushNamed(NoticesTab.tag);
            break;
          case "timetable":
            globalWaitAndPushNamed(TimetableTab.tag);
            break;
          case "exam":
            globalWaitAndPushNamed(ExamsTab.tag);
            break;
          case "average":
            globalWaitAndPushNamed(StatisticsTab.tag);
            break;
          case "event":
            globalWaitAndPushNamed(EventsTab.tag);
            break;
          case "absence":
            globalWaitAndPushNamed(AbsencesTab.tag);
            break;
          default:
            //FIXME: Handle unknown payloads
            break;
        }
      } else {
        //*If content is suplied, then we should fetch it and show it
        switch (payloadPrefix) {
          case "marks":
            globalWaitAndPushNamed(MarksTab.tag);
            break;
          case "hw":
            globalWaitAndPushNamed(HomeworkTab.tag);
            break;
          case "notice":
            globalWaitAndPushNamed(NoticesTab.tag);
            break;
          case "timetable":
            globalWaitAndPushNamed(TimetableTab.tag);
            break;
          case "exam":
            globalWaitAndPushNamed(ExamsTab.tag);
            break;
          case "average":
            globalWaitAndPushNamed(StatisticsTab.tag);
            break;
          case "event":
            globalWaitAndPushNamed(EventsTab.tag);
            break;
          case "absence":
            globalWaitAndPushNamed(AbsencesTab.tag);
            break;
          default:
            //FIXME: Handle unknown payloads
            break;
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Handle notification select',
        printDetails: true,
      );
    }
  }

  static Future<void> Function(
    int,
    String,
    String,
    NotificationDetails, {
    String payload,
  }) show = flutterLocalNotificationsPlugin.show;

  static Future<void> Function(
    int,
  ) cancel = flutterLocalNotificationsPlugin.cancel;
}

Future<void> globalWaitAndPushNamed(String tag) async {
  if (globals.isLoaded) {
    NavigatorKey.navigatorKey.currentState.pushNamed(tag);
  } else {
    await waitWhile(() => globals.isLoaded);
    print("LOADED");
    NavigatorKey.navigatorKey.currentState.pushNamed(tag);
  }
}
