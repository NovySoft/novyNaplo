import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/global.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/helpers/notificationHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/database/getSql.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'package:sqflite/sqflite.dart';

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
var platformChannelSpecificsGetNotif =
    new NotificationDetails(androidFetchDetail, iOSPlatformChannelSpecifics);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
AndroidNotificationDetails sendNotification;
NotificationDetails platformChannelSpecificsSendNotif;
int notifId = 2;

void backgroundFetch() async {
  FirebaseAnalytics().logEvent(name: "BackgroundFetch");
  Crashlytics.instance.log("backgroundFetch started");
  vibrationPattern = new Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 500;
  vibrationPattern[3] = 1000;
  sendNotification = new AndroidNotificationDetails(
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
  platformChannelSpecificsSendNotif =
      new NotificationDetails(sendNotification, iOSPlatformChannelSpecifics);
  if (await Connectivity().checkConnectivity() == ConnectivityResult.none)
    return;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin.show(
    111,
    'Adatok lekérése',
    'Éppen zajlik az adatok lekérése...',
    platformChannelSpecificsGetNotif,
  );
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=$isolateId function='$backgroundFetch'");
  final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
  var passKey = encrypt.Key.fromUtf8(config.passKey);
  var codeKey = encrypt.Key.fromUtf8(config.codeKey);
  var userKey = encrypt.Key.fromUtf8(config.userKey);
  final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
  final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
  final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
  String decryptedCode =
      codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
  if (decryptedCode == null || decryptedCode == "") return;
  String decryptedUser =
      userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
  String decryptedPass =
      passEncrypter.decrypt64(prefs.getString("password"), iv: iv);
  var status = "";
  await mainSql.initDatabase();
  for (var i = 0; i < 2; i++) {
    status = await NetworkHelper()
        .getToken(decryptedCode, decryptedUser, decryptedPass);
  }
  if (status == "OK") {
    //print(globals.token);
    String token = globals.token;
    var headers = {
      'Authorization': 'Bearer $token',
      'User-Agent': '$agent',
    };
    var res = await http.get(
        'https://$decryptedCode.e-kreta.hu/mapi/api/v1/StudentAmi?fromDate=null&toDate=null',
        headers: headers);
    if (res.statusCode == 200) {
      globals.dJson = json.decode(res.body);
      await parseAllByDateFetch(globals.dJson);
      await getAvaragesFetch(token, decryptedCode);
      await parseNoticesFetch(globals.dJson);
    }
  }
  await flutterLocalNotificationsPlugin.cancel(111);
}

Future<List<dynamic>> parseAllByDateFetch(var input) async {
  List<Evals> jegyArray = [];
  //! TODO fix this duplicate code
  try {
    var jegyek = input["Evaluations"];
    jegyArray = [];
    for (var n in jegyek) {
      jegyArray.add(setEvals(n));
    }
  } catch (e) {
    return [];
  }
  jegyArray.sort((a, b) => b.createDateString.compareTo(a.createDateString));
  await batchInsertEvalAndSendNotif(jegyArray);
  return jegyArray;
}

Future<void> batchInsertEvalAndSendNotif(List<Evals> evalList) async {
  Crashlytics.instance.log("batchInsertEvalAndNotif");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();
  await sleep1();
  //Get all evals, and see whether we should be just replacing
  List<Evals> allEvals = await getAllEvals();
  for (var eval in evalList) {
    notifId = notifId == 111 ? notifId + 2 : notifId + 1;
    var matchedEvals = allEvals.where(
      (element) {
        return (element.id == eval.id && element.form == eval.form) ||
            (element.subject == eval.subject &&
                element.id == eval.id &&
                element.form == eval.form);
      },
    );
    if (matchedEvals.length == 0) {
      batch.insert(
        'Evals',
        eval.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (notifId == 111) {
        notifId = notifId == 111 ? notifId + 2 : notifId + 1;
      }
      //print("notifID: $notifId");
      await flutterLocalNotificationsPlugin.show(
        notifId,
        'Új jegy: ' + capitalize(eval.subject) + " " + eval.value,
        'Téma: ' + eval.theme,
        platformChannelSpecificsSendNotif,
        payload: "marks " + eval.id.toString(),
      );
    } else {
      for (var n in matchedEvals) {
        //!Update didn't work so we delete and create a new one
        if ((n.numberValue != eval.numberValue ||
                n.theme != eval.theme ||
                n.dateString != eval.dateString ||
                n.weight != eval.weight) &&
            n.id == eval.id) {
          batch.delete(
            "Evals",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Evals',
            eval.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          var tempRequests = await flutterLocalNotificationsPlugin
              .pendingNotificationRequests();
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          //print("notifID: $notifId");
          await flutterLocalNotificationsPlugin.show(
            notifId,
            'Jegy módosult: ' + capitalize(eval.subject) + " " + eval.value,
            'Téma: ' + eval.theme,
            platformChannelSpecificsSendNotif,
            payload: "marks " + eval.id.toString(),
          );
        }
      }
    }
  }
  await batch.commit();
  ////print("INSERTED EVAL BATCH");
}

Future<void> getAvaragesFetch(var token, code) async {
  var headers = {
    'Authorization': 'Bearer $token',
    'User-Agent': '$agent',
  };

  var res = await http.get(
      'https://$code.e-kreta.hu/mapi/api/v1/TantargyiAtlagAmi',
      headers: headers);
  if (res.statusCode != 200)
    throw Exception('get error: statusCode= ${res.statusCode}');
  if (res.statusCode == 200) {
    var bodyJson = json.decode(res.body);
    await parseAvFetch(bodyJson);
  }
}

Future<void> parseAvFetch(var input) async {
  List<Avarage> atlagArray = [];
  try {
    for (var n in input) {
      atlagArray.add(setAvarage(
          n["Subject"], n["Value"], n["classValue"], n["Difference"]));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAvarages');
    return [];
  }
  await batchInsertAvarageAndNotif(atlagArray);
}

Future<void> batchInsertAvarageAndNotif(List<Avarage> avarageList) async {
  Crashlytics.instance.log("batchInsertAvarageAndNotif");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();
  await sleep1();
  List<Avarage> allAv = await getAllAvarages();
  for (var avarage in avarageList) {
    var matchedAv = allAv.where((element) {
      return (element.subject == avarage.subject);
    });
    if (matchedAv.length == 0) {
      batch.insert(
        'Avarage',
        avarage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedAv) {
        //!Update didn't work so we delete and create a new one
        if (n.diff != avarage.diff ||
            n.ownValue != avarage.ownValue ||
            n.classValue != avarage.classValue) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          batch.delete(
            "Avarage",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Avarage',
            avarage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          double diffValue = avarage.ownValue - n.ownValue;
          String diff = diffValue < 0
              ? ("-${diffValue.toString()}")
              : diffValue.toString();
          await flutterLocalNotificationsPlugin.show(
            notifId,
            'Átlag módosult: ' + capitalize(avarage.subject),
            'Új átlag: ' + avarage.ownValue.toString() + " ($diff)",
            platformChannelSpecificsSendNotif,
            payload: "avarage 0",
          );
        }
      }
    }
  }
  await batch.commit();
}

Future<List<Notices>> parseNoticesFetch(var input) async {
  if (input != null && input["Notes"] != null) {
    List<Notices> noticesArray = [];
    var notices = input["Notes"];
    for (var n in notices) {
      noticesArray.add(setNotices(n));
    }
    await batchInsertNoticesAndNotif(noticesArray);
    return noticesArray;
  } else {
    return [];
  }
}

Future<void> batchInsertNoticesAndNotif(List<Notices> noticeList) async {
  Crashlytics.instance.log("batchInsertNoticesAndNotif");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();
  await sleep1();
  List<Notices> allNotices = await getAllNotices();
  for (var notice in noticeList) {
    var matchedNotices = allNotices.where((element) {
      return (element.title == notice.title || element.id == notice.id);
    });
    if (matchedNotices.length == 0) {
      batch.insert(
        'Notices',
        notice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      notifId = notifId == 111 ? notifId + 2 : notifId + 1;
      await flutterLocalNotificationsPlugin.show(
        notifId,
        'Új feljegyzés: ' + capitalize(notice.title),
        notice.teacher,
        platformChannelSpecificsSendNotif,
        payload: "notice " + notice.id.toString(),
      );
    } else {
      for (var n in matchedNotices) {
        //!Update didn't work so we delete and create a new one
        if ((n.title != notice.title || n.content != notice.content) &&
            n.id == notice.id) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          batch.delete(
            "Notices",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Notices',
            notice.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          await flutterLocalNotificationsPlugin.show(
            notifId,
            'Feljegyzés módusolt: ' + capitalize(notice.title),
            notice.teacher,
            platformChannelSpecificsSendNotif,
            payload: "notice " + notice.id.toString(),
          );
        }
      }
    }
  }
  await batch.commit();
  //print("BATCH INSERTED NOTICES");
}
