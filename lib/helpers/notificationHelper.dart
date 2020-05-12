import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/global.dart' as globals;
//TODO group notifications
//TODO move this to a different file
Int64List vibrationPattern;
var androidPlatformChannelSpecifics;
var iOSPlatformChannelSpecifics;
var platformChannelSpecifics;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void setupNotifications() async{
  vibrationPattern = new Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 50;
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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    NotificationAppLaunchDetails notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    print(notificationAppLaunchDetails.didNotificationLaunchApp);
    print(notificationAppLaunchDetails.payload);
}

Future selectNotification(String payload) async {
    if (ModalRoute.of(globals.globalContext).settings.name == "/") return;
    if (payload != null && payload != "teszt" && payload is String) {
      print(payload);
      showDialog<void>(
        context: globals.globalContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Értesítés'),
            content: Text(payload),
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