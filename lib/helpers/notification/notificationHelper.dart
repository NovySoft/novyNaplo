import 'dart:typed_data';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notificationReceiver.dart';

class NotificationHelper {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static AndroidNotificationDetails androidPlatformChannelSpecifics;
  static IOSNotificationDetails iOSPlatformChannelSpecifics;

  ///Normal notification, alert summary only behaviour
  static NotificationDetails platformChannelSpecifics;

  ///Alert all behaviour
  static NotificationDetails platformChannelSpecificsAlertAll;

  ///The summary notification
  static NotificationDetails platformChannelSpecificsSummary;
  static Int64List vibrationPattern;

  static Future<void> setupNotifications() async {
    FirebaseCrashlytics.instance.log("setupNotifications");
    vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 300;
    vibrationPattern[1] = 100;
    vibrationPattern[2] = 300;
    vibrationPattern[3] = 300;
    //Normal notifications when summarizing
    androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'novynaplo',
      'novynaplo',
      'Channel for sending novyNaplo main notifications',
      groupKey: "novy.vip.novynaplo.MAIN_NOTIFICATIONS",
      groupAlertBehavior: GroupAlertBehavior.summary,
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

    //? Alert all notifications
    var androidPlatformChannelSpecificsAlertAll =
        new AndroidNotificationDetails(
      'novynaplo',
      'novynaplo',
      'Channel for sending novyNaplo main notifications',
      groupKey: "novy.vip.novynaplo.MAIN_NOTIFICATIONS",
      groupAlertBehavior: GroupAlertBehavior.all,
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
    var iOSPlatformChannelSpecificsAlertAll = new IOSNotificationDetails();
    platformChannelSpecificsAlertAll = new NotificationDetails(
      android: androidPlatformChannelSpecificsAlertAll,
      iOS: iOSPlatformChannelSpecificsAlertAll,
    );

    //?Summary notifications
    var androidPlatformChannelSpecificsSummary = new AndroidNotificationDetails(
      'novynaplo',
      'novynaplo',
      'Channel for sending novyNaplo main notifications',
      groupKey: "novy.vip.novynaplo.MAIN_NOTIFICATIONS",
      setAsGroupSummary: true,
      groupAlertBehavior: GroupAlertBehavior.summary,
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
    var iOSPlatformChannelSpecificsSummary = new IOSNotificationDetails();
    platformChannelSpecificsSummary = new NotificationDetails(
      android: androidPlatformChannelSpecificsSummary,
      iOS: iOSPlatformChannelSpecificsSummary,
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
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: NotificationReceiver.selectNotification,
    );
  }

  static Future<void> Function(
    int id,
    String title,
    String body,
    NotificationDetails notificationDetails, {
    String payload,
  }) show = flutterLocalNotificationsPlugin.show;

  static Future<void> Function(
    int,
  ) cancel = flutterLocalNotificationsPlugin.cancel;

  static Future<void> Function() cancelAll =
      flutterLocalNotificationsPlugin.cancelAll;
}
