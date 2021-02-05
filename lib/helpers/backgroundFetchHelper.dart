import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/database/users.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/helpers/notification/notificationHelper.dart';

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
    await NotificationHelper.setupNotifications();
    await DatabaseHelper.initDatabase();
    //Check for network connectivity
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return;
    }
    if (globals.backgroundFetchOnCellular == false &&
        await Connectivity().checkConnectivity() == ConnectivityResult.mobile) {
      return;
    }
    List<Student> allUsers = await DatabaseHelper.getAllUsers();
    int errorNotifId = -1;
    for (var currentUser in allUsers) {
      TokenResponse status = await RequestHandler.login(currentUser);
      if (status.status == "OK") {
        await RequestHandler.getEverything(
          status.userinfo,
          setData: false,
        );
        FirebaseAnalytics().logEvent(name: "BackgroundFetchSuccess");
      } else if (status.status == "invalid_username_or_password") {
        String name = await getUsersNameFromUserId(currentUser.userId);
        await NotificationHelper.show(
          errorNotifId,
          '${getTranslatedString("XPassWrong", replaceVariables: [name])}',
          '${getTranslatedString("ComeAndChangePass")}',
          NotificationHelper.platformChannelSpecificsAlertAll,
        );
        errorNotifId -= 1;
      } else {
        FirebaseAnalytics().logEvent(
          name: "BackgroundFetchFail",
          parameters: {
            "status": status.status,
          },
        );
      }
    }
  } catch (e, s) {
    FirebaseAnalytics().logEvent(name: "BackgroundFetchError");
    FirebaseCrashlytics.instance.recordError(
      e,
      s,
      reason: 'backgroundFetch',
      printDetails: true,
    );
    await NotificationHelper.show(
      -111,
      '${getTranslatedString("errWhileFetch")}',
      e.toString(),
      NotificationHelper.platformChannelSpecificsAlertAll,
    );
  }
}
