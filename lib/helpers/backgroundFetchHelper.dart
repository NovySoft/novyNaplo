import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/global.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/screens/homework_tab.dart' as homeworkPage;
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
  //print("[$now] Hello, world! isolate=$isolateId function='$backgroundFetch'");
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
      await parseAllByDateFetch(globals.dJson); //Evals
      await getAvaragesFetch(token, decryptedCode); //Avarages
      await parseNoticesFetch(globals.dJson); //Notices
      await getWeekLessonsFetch(token, decryptedCode); //Homework and Timetable
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
          String diff = diffValue > 0
              ? ("+${diffValue.toString()}")
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

Future<List<List<Lesson>>> getWeekLessonsFetch(token, code) async {
  List<List<Lesson>> output = [];
  for (var n = 0; n < 7; n++) {
    output.add([]);
  }
  //calculate when was monday this week
  int monday = 1;
  int sunday = 7;
  DateTime now = new DateTime.now();

  while (now.weekday != monday) {
    now = now.subtract(new Duration(days: 1));
  }
  String startDate = now.year.toString() +
      "-" +
      now.month.toString() +
      "-" +
      now.day.toString();
  now = new DateTime.now();
  while (now.weekday != sunday) {
    now = now.add(new Duration(days: 1));
  }
  String endDate = now.year.toString() +
      "-" +
      now.month.toString() +
      "-" +
      now.day.toString();
  //Make request
  var header = {
    'Authorization': 'Bearer $token',
    'User-Agent': '$agent',
    'Content-Type': 'application/json',
  };

  var res = await http.get(
      'https://$code.e-kreta.hu/mapi/api/v1/LessonAmi?fromDate=$startDate&toDate=$endDate',
      headers: header);
  if (res.statusCode != 200) {
    print(res.statusCode);
  }
  //Process response
  var decoded = json.decode(res.body);
  List<Lesson> tempLessonList = [];
  List<Lesson> tempLessonListForDB = [];
  for (var n in decoded) {
    tempLessonList.add(await setLessonFetch(n, token, code));
  }
  tempLessonList.sort((a, b) => a.startDate.compareTo(b.startDate));
  int index = 0;
  if (tempLessonList != null) {
    if (tempLessonList.length != 0) {
      int beforeDay = tempLessonList[0].startDate.day;
      //Just a matrix
      for (var n in tempLessonList) {
        if (n.startDate.day != beforeDay) {
          index++;
          beforeDay = n.startDate.day;
        }
        output[index].add(n);
        tempLessonListForDB.add(n);
      }
      await batchInsertLessonsAndNotif(tempLessonListForDB);
    }
  }
  return output;
}

Future<void> batchInsertLessonsAndNotif(List<Lesson> lessonList) async {
  Crashlytics.instance.log("batchInsertEvalAndNotif");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  final Batch batch = db.batch();
  await sleep1();
  //Get all evals, and see whether we should be just replacing
  List<Lesson> allTimetable = await getAllTimetable();
  for (var lesson in lessonList) {
    var matchedLessons = allTimetable.where(
      (element) {
        return (element.id == lesson.id && element.subject == lesson.subject);
      },
    );
    if (matchedLessons.length == 0) {
      batch.insert(
        'Timetable',
        lesson.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      for (var n in matchedLessons) {
        //!Update didn't work so we delete and create a new one
        if (n.theme != lesson.theme ||
            n.teacher != lesson.teacher ||
            n.dateString != lesson.dateString ||
            n.deputyTeacherName != lesson.deputyTeacherName ||
            n.name != lesson.name ||
            n.classroom != lesson.classroom ||
            n.homeWorkId != lesson.homeWorkId ||
            n.teacherHomeworkId != lesson.teacherHomeworkId ||
            json.encode(n.dogaIds) != json.encode(lesson.dogaIds) ||
            n.startDateString != lesson.startDateString ||
            n.endDateString != lesson.endDateString) {
          notifId = notifId == 111 ? notifId + 2 : notifId + 1;
          batch.delete(
            "Timetable",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Timetable',
            lesson.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          String subTitle = "";
          if (lesson.theme != null && lesson.theme != "") {
            subTitle = lesson.theme;
          } else if (lesson.teacher != null && lesson.teacher != "") {
            subTitle = lesson.teacher;
          } else if (lesson.deputyTeacherName != null &&
              lesson.deputyTeacherName != "") {
            subTitle = lesson.deputyTeacherName;
          } else {
            subTitle = lesson.classroom;
          }
          await flutterLocalNotificationsPlugin.show(
            notifId,
            'Módusolt tanóra: ' +
                capitalize(lesson.subject) +
                " (${parseIntToWeekdayString(lesson.date.weekday)})",
            subTitle,
            platformChannelSpecificsSendNotif,
            payload: "timetable " + lesson.id.toString(),
          );
        }
      }
    }
  }
  await batch.commit();
  //print("INSERTED EVAL BATCH");
}

Future<Lesson> setLessonFetch(var input, token, code) async {
  var temp = new Lesson();
  //INTs
  temp.id = input["LessonId"];
  temp.whichLesson = input["Count"];
  temp.homeWorkId = input["Homework"];
  temp.groupID = input["OsztalyCsoportId"];
  temp.teacherHomeworkId = input["TeacherHomeworkId"];
  //Strings
  temp.groupName = input["ClassGroup"];
  temp.subject = capitalize(input["Subject"]);
  temp.name = capitalize(input["Nev"]);
  if (input["ClassRoom"].toString().startsWith("I")) {
    temp.classroom = input["ClassRoom"];
  } else {
    temp.classroom = capitalize(input["ClassRoom"]);
  }
  temp.theme = input["Theme"];
  temp.teacher = input["Teacher"];
  temp.deputyTeacherName = input["DeputyTeacher"];
  //DateTimes
  temp.startDate = DateTime.parse(input["StartTime"]);
  temp.endDate = DateTime.parse(input["EndTime"]);
  temp.date = DateTime.parse(input["Date"]);
  //Datetime sttring
  temp.startDateString = input["StartTime"];
  temp.endDateString = input["EndTime"];
  temp.dateString = input["Date"];
  //Booleans
  temp.homeworkEnabled = input["IsTanuloHaziFeladatEnabled"];
  //Lists
  temp.dogaIds = input["BejelentettSzamonkeresIdList"];
  temp.dogaNames = []; //TODO EZT MEGCSINÁLNI
  if (temp.teacherHomeworkId != null) {
    temp.homework =
        await setTeacherHomeworkFetch(temp.teacherHomeworkId, token, code);
  } else {
    temp.homework = new Homework();
  }
  return temp;
}

Future<Homework> setTeacherHomeworkFetch(
    int hwId, String token, String code) async {
  var header = {
    'Authorization': 'Bearer $token',
    'User-Agent': '$agent',
    'Content-Type': 'application/json',
  };

  var res = await http.get(
      'https://$code.e-kreta.hu/mapi/api/v1/HaziFeladat/TanarHaziFeladat/$hwId',
      headers: header);
  if (res.statusCode != 200) {
    print(res.statusCode);
    return new Homework();
  }
  //Process response
  var decoded = json.decode(res.body);
  Homework temp = setHomework(decoded);
  await insertHomeworkAndNotif(temp);
  return temp;
}

Future<void> insertHomeworkAndNotif(Homework hw) async {
  Crashlytics.instance.log("insertSingleHw");
  // Get a reference to the database.
  final Database db = await mainSql.database;
  await sleep1();
  List<Homework> allHw = await getAllHomework();
  var matchedHw = allHw.where((element) {
    return (element.id == hw.id && element.subject == hw.subject);
  });
  if (matchedHw.length == 0) {
    notifId = notifId == 111 ? notifId + 2 : notifId + 1;
    await db.insert(
      'Homework',
      hw.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    String subTitle = "Határidő: " +
        hw.dueDate.year.toString() +
        "-" +
        hw.dueDate.month.toString() +
        "-" +
        hw.dueDate.day.toString() +
        " " +
        parseIntToWeekdayString(hw.dueDate.weekday);
    await flutterLocalNotificationsPlugin.show(
      notifId,
      'Új házifeladat: ' + capitalize(hw.subject),
      subTitle,
      platformChannelSpecificsSendNotif,
      payload: "hw " + hw.id.toString(),
    );
  } else {
    for (var n in matchedHw) {
      //!Update didn't work so we delete and create a new one
      if (n.content != hw.content ||
          n.dueDateString != hw.dueDateString ||
          n.givenUpString != hw.givenUpString) {
        notifId = notifId == 111 ? notifId + 2 : notifId + 1;
        deleteFromDb(n.databaseId, "Homework");
        insertHomework(hw);
        String subTitle = "Határidő: " +
            hw.dueDate.year.toString() +
            "-" +
            hw.dueDate.month.toString() +
            "-" +
            hw.dueDate.day.toString() +
            " " +
            parseIntToWeekdayString(hw.dueDate.weekday);
        await flutterLocalNotificationsPlugin.show(
          notifId,
          'Módusolt házifeladat: ' + capitalize(hw.subject),
          subTitle,
          platformChannelSpecificsSendNotif,
          payload: "hw " + hw.id.toString(),
        );
      }
    }
  }
}
