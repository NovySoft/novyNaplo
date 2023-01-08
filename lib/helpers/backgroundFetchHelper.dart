import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/API/certValidation.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/helpers/notification/notificationHelper.dart';

var androidFetchDetail = new AndroidNotificationDetails(
  'novynaplo02',
  'novynaplo2',
  channelDescription: 'Channel for sending novyNaplo load notifications',
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

@pragma('vm:entry-point')
Future<void> backgroundFetch() async {
  print("BACKGROUND FETCH");
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseAnalytics.instance.logEvent(name: "BackgroundFetch");
    FirebaseAnalytics.instance
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
    globals.allUsers = await DatabaseHelper.getAllUsers();
    trustedCerts = await DatabaseHelper.getTrustedCerts();
    //int errorNotifId = -1;
    for (var currentUser in globals.allUsers) {
      TokenResponse status = await RequestHandler.login(currentUser);
      if (status.status == "OK") {
        await RequestHandler.getEverything(
          status.userinfo,
          setData: false,
        );
        FirebaseAnalytics.instance.logEvent(name: "BackgroundFetchSuccess");
      }
      //!Kréta update fucks up and says that password is wrong, but in reality it is an update
      /*else if (status.status == "invalid_username_or_password") {
        String name = await getUsersNameFromUserId(currentUser.userId);
        await NotificationHelper.show(
          errorNotifId,
          '${getTranslatedString("XPassWrong", replaceVariables: [name])}',
          '${getTranslatedString("ComeAndChangePass")}',
          NotificationHelper.platformChannelSpecificsAlertAll,
        );
        errorNotifId -= 1;
      }*/
      else {
        if (!status.status.contains(getTranslatedString('kretaUpgrade'))) {
          FirebaseAnalytics.instance.logEvent(
            name: "BackgroundFetchFail",
            parameters: {
              "status": status.status,
            },
          );
        }
      }
    }
    if (globals.notifications) {
      await NotificationDispatcher.dispatchNotifications();
    } else {
      //Clear the notification list if we are not sending it -> otherwise the next time it will send them.
      NotificationDispatcher.toBeDispatchedNotifications =
          ToBeDispatchedNotifications();
    }
  } catch (e, s) {
    FirebaseAnalytics.instance.logEvent(name: "BackgroundFetchError");
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
  } finally {
    print("BACKGROUND ENDED");
    FirebaseCrashlytics.instance.log("BackgroundFetch ended");
  }
}
