import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/helpers/decryptionHelper.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/data/database/mainSql.dart' as mainSql;
import 'package:novynaplo/helpers/notificationHelper.dart' as notifHelper;
import 'package:novynaplo/i18n/translationProvider.dart';

//FIXME Fix the background fetch errors, I mean we also need to rewrite this
//FIXME:Create a notificationDispatch helper and make "contracted notifications", eg. 15 new marks
var androidFetchDetail = new AndroidNotificationDetails(
  'novynaplo02',
  'novynaplo2',
  'Channel for sending novyNaplo load notifications',
  importance: Importance.low,
  priority: Priority.low,
  enableVibration: false,
  enableLights: false,
  playSound: false,
  color: Color.fromARGB(255, 255, 165, 0),
  visibility: NotificationVisibility.public,
);
var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
var platformChannelSpecificsGetNotif = new NotificationDetails(
    android: androidFetchDetail, iOS: iOSPlatformChannelSpecifics);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
AndroidNotificationDetails sendNotification;
NotificationDetails platformChannelSpecificsSendNotif;
int notifId = 2;

void backgroundFetch() async {
  print("BACKGROUND FETCH");
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseAnalytics().logEvent(name: "BackgroundFetch");
    FirebaseAnalytics()
        .setUserProperty(name: "Version", value: config.currentAppVersionCode);
    FirebaseCrashlytics.instance
        .setCustomKey("Version", config.currentAppVersionCode);
    FirebaseCrashlytics.instance.log("backgroundFetch started");
    await globals.setGlobals();
    await notifHelper.setupNotifications();
    //print(globals.notifications);
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return;
    }
    if (globals.prefs.getBool("backgroundFetchOnCellular") == false &&
        await Connectivity().checkConnectivity() == ConnectivityResult.mobile) {
      return;
    }
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await flutterLocalNotificationsPlugin.show(
      111,
      getTranslatedString("gettingData"),
      '${getTranslatedString("currGetData")}...',
      platformChannelSpecificsGetNotif,
    );
    /*final DateTime now = DateTime.now();
    final int isolateId = Isolate.current.hashCode;
    print("[$now] Hello, world! isolate=$isolateId function='$backgroundFetch'");*/
    await decryptUserDetails();
    if (globals.userDetails.school == null ||
        globals.userDetails.school == "") {
      await flutterLocalNotificationsPlugin.cancel(111);
      await flutterLocalNotificationsPlugin.show(
        -111,
        '${getTranslatedString("errWhileFetch")}:',
        "Decryption error",
        platformChannelSpecificsSendNotif,
      );
      return;
    }
    await mainSql.initDatabase();
    String status = await RequestHandler.login(globals.userDetails);
    if (status == "OK") {
      //print( globals.userDetails.token);
      String token = globals.userDetails.token;
      //await NetworkHelper().getStudentInfo(token, decryptedCode);
    }
    await flutterLocalNotificationsPlugin.cancel(111);
  } catch (e, s) {
    FirebaseCrashlytics.instance.recordError(e, s, reason: 'backgroundFetch');
    await flutterLocalNotificationsPlugin.cancel(111);
    await flutterLocalNotificationsPlugin.show(
      -111,
      '${getTranslatedString("errWhileFetch")}',
      e.toString(),
      platformChannelSpecificsSendNotif,
    );
  }
}
