import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:novynaplo/helpers/notificationHelper.dart';

var androidFetchDetail = new AndroidNotificationDetails(
  'novynaplo02',
  'novynaplo2',
  'Channel for sending novyNaplo load notifications',
  importance: Importance.Low,
  priority: Priority.Low,
  enableVibration: false,
  enableLights: false,
  playSound: false,
  color: Color.fromARGB(255, 255, 165, 0),
  visibility: NotificationVisibility.Public,
);
var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
var platformChannelSpecifics =
    new NotificationDetails(androidFetchDetail, iOSPlatformChannelSpecifics);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void backgroundFetch() async {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin.show(
    111,
    'Adatok lekérése',
    'Éppen zajlik az adatok lekérése...',
    platformChannelSpecifics,
  );
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=$isolateId function='$backgroundFetch'");
  await sleep(2500);
  await flutterLocalNotificationsPlugin.cancel(111);
}
