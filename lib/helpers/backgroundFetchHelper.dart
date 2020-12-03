import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/data/database/mainSql.dart' as mainSql;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/helpers/notificationHelper.dart' as notifHelper;
import 'package:novynaplo/i18n/translationProvider.dart';

//FIXME Fix the background fetch errors
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return;
    }
    if (prefs.getBool("backgroundFetchOnCellular") == false &&
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
    final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
    var passKey = encrypt.Key.fromUtf8(config.passKey);
    var codeKey = encrypt.Key.fromUtf8(config.codeKey);
    var userKey = encrypt.Key.fromUtf8(config.userKey);
    final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
    final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
    final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
    String decryptedCode =
        codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
    if (decryptedCode == null || decryptedCode == "") {
      await flutterLocalNotificationsPlugin.cancel(111);
      await flutterLocalNotificationsPlugin.show(
        -111,
        '${getTranslatedString("errWhileFetch")}:',
        "Decryption error",
        platformChannelSpecificsSendNotif,
      );
      return;
    }
    //TODO MAKE DECRYPT HELPER
    String decryptedUser =
        userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
    String decryptedPass =
        passEncrypter.decrypt64(prefs.getString("password"), iv: iv);
    globals.userDetails.password = decryptedPass;
    globals.userDetails.username = decryptedUser;
    globals.userDetails.school = decryptedCode;
    await mainSql.initDatabase();
    String status = await RequestHandler.login(globals.userDetails);
    if (status == "OK") {
      //print( globals.userDetails.token);
      String token = globals.userDetails.token;
      await NetworkHelper().getStudentInfo(token, decryptedCode);
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
