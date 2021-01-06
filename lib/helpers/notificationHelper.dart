import 'dart:typed_data';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/global.dart' as globals;

class NotificationHelper {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static AndroidNotificationDetails androidPlatformChannelSpecifics;
  static IOSNotificationDetails iOSPlatformChannelSpecifics;
  static NotificationDetails platformChannelSpecifics;
  static Int64List vibrationPattern;

  static Future<void> setupNotifications() async {
    FirebaseCrashlytics.instance.log("setupNotifications");
    vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 1000;
    androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'novynaplo01',
      'novynaplo',
      'Channel for sending novyNaplo notifications',
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
    globals.notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  static Future<void> selectNotification(String payload) async {
    FirebaseCrashlytics.instance
        .log("selectNotification received (payload $payload)");
    print(payload);
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
