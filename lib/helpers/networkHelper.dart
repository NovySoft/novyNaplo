import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/database/insertSql.dart';
import 'package:novynaplo/data/models/calculator.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/school.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/parsing/parseAbsences.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseEvents.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseExams.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseNotices.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/ui/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:novynaplo/config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/API/requestHandler.dart';

String agent = config.userAgent;
var response;
int tokenIndex = 0;

//TODO: UPDATE TO API V3, ONLY WHEN IT WILL BE STABLE TO USE
class NetworkHelper {
  Future<ConnectivityResult> isNetworkAvailable() async {
    return await (Connectivity().checkConnectivity());
  }

  Future<void> getEvents(token, code) async {
    FirebaseCrashlytics.instance.log("getEvents");
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'User-Agent': '$agent',
      };

      var res = await http.get('https://$code.e-kreta.hu/mapi/api/v1/EventAmi',
          headers: headers);
      if (res.statusCode != 200)
        throw Exception('get error: statusCode= ${res.statusCode}');
      if (res.statusCode == 200) {
        var bodyJson = json.decode(res.body);
        eventsPage.allParsedEvents = await parseEvents(bodyJson);
        eventsPage.allParsedEvents.sort((a, b) => b.date.compareTo(a.date));
        await batchInsertEvents(eventsPage.allParsedEvents);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'getEvents');
    }
  }

  Future<void> getStudentInfo(token, code) async {
    FirebaseCrashlytics.instance.log("getStudentInfo");
    var headers = {
      'Authorization': 'Bearer $token',
      'User-Agent': '$agent',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/StudentAmi?fromDate=null&toDate=null',
        headers: headers);
    if (res.statusCode != 200)
      throw Exception('get error: statusCode= ${res.statusCode}');
    if (res.statusCode == 200) {
      globals.dJson = json.decode(res.body);
      if (!config.isAppPlaystoreRelease) {
        FirebaseCrashlytics.instance.setUserIdentifier(globals.dJson["Name"]);
        FirebaseCrashlytics.instance
            .setCustomKey("User", globals.dJson["Name"]);
      }
      await getExams(token, code);
      await getEvents(token, code);
      marksPage.allParsedByDate = await parseAllByDate(globals.dJson);
      marksPage.colors = getRandomColors(marksPage.allParsedByDate.length);
      marksPage.allParsedBySubject =
          sortByDateAndSubject(List.from(marksPage.allParsedByDate));
      noticesPage.allParsedNotices = await parseNotices(globals.dJson);
      statisticsPage.allParsedSubjects = categorizeSubjectsFromEvals(
        new List.from(
          marksPage.allParsedByDate,
        ),
      );
      statisticsPage.allParsedSubjectsWithoutZeros = List.from(
        statisticsPage.allParsedSubjects
            .where((element) => element[0].szamErtek != 0),
      );
      timetablePage.lessonsList = await getThisWeeksLessons(token, code);
      setUpCalculatorPage(statisticsPage.allParsedSubjects);
    }
  }

  Future<List<List<Lesson>>> getSpecifiedWeeksLesson(date) async {
    FirebaseCrashlytics.instance.log("getSpecifiedWeeksLesson");
    if (await NetworkHelper().isNetworkAvailable() == ConnectivityResult.none) {
      throw Exception(getTranslatedString("noNet"));
    }
    String code = "";
    // ignore: unused_local_variable
    String decryptedPass, decryptedUser, decryptedCode, status;
    status = "";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var codeKey = encrypt.Key.fromUtf8(config.codeKey);
    final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
    final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
    decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
    code = decryptedCode;
    if (globals.userDetails.tokenDate == null) {
      globals.userDetails.tokenDate = DateTime.now().subtract(
        Duration(
          minutes: 30,
        ),
      );
    }
    if (DateTime.now().isAfter(
      globals.userDetails.tokenDate.add(
        Duration(minutes: 20),
      ),
    )) {
      var passKey = encrypt.Key.fromUtf8(config.passKey);
      var userKey = encrypt.Key.fromUtf8(config.userKey);
      final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
      final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
      decryptedUser = userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
      decryptedPass =
          passEncrypter.decrypt64(prefs.getString("password"), iv: iv);
      String status = await RequestHandler.login(globals.userDetails);
      //TODO Handle errors
    }
    List<List<Lesson>> output = [];
    for (var n = 0; n < 7; n++) {
      output.add([]);
    }
    //calculate when was monday this week
    int monday = 1;
    int sunday = 7;
    DateTime now = date;
    timetablePage.fetchedDayList.add(now);
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    String startDate = now.year.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.day.toString();
    now = date;
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    String endDate = now.year.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.day.toString();
    //Make request
    var header = {
      'Authorization': 'Bearer ${globals.userDetails.token}',
      'User-Agent': '$agent',
      'Content-Type': 'application/json',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/LessonAmi?fromDate=$startDate&toDate=$endDate',
        headers: header);
    if (res.statusCode != 200) {
      print(res.statusCode);
      throw Exception("HTTP GET ERROR ${res.statusCode}");
    }
    //Process response
    var decoded = json.decode(res.body);
    List<Lesson> tempLessonList = [];
    List<Lesson> tempLessonListForDB = [];
    for (var n in decoded) {
      tempLessonList.add(await Lesson.fromJson(n));
    }
    tempLessonList.sort((a, b) => a.kezdetIdopont.compareTo(b.kezdetIdopont));
    int index = 0;
    if (tempLessonList != null) {
      if (tempLessonList.length != 0) {
        int beforeDay = tempLessonList[0].kezdetIdopont.day;
        //Just a matrix
        for (var n in tempLessonList) {
          if (n.kezdetIdopont.day != beforeDay) {
            index++;
            beforeDay = n.kezdetIdopont.day;
          }
          output[index].add(n);
          tempLessonListForDB.add(n);
        }
        /*await batchInsertLessons(
          tempLessonListForDB,
          lookAtDate: true,
        );*/
      }
    }
    return output;
  }

  Future<List<List<Lesson>>> getThisWeeksLessons(token, code) async {
    FirebaseCrashlytics.instance.log("getThisWeeksLessons");
    List<List<Lesson>> output = [];
    for (var n = 0; n < 7; n++) {
      output.add([]);
    }
    //calculate when was monday this week
    int monday = 1;
    int sunday = 7;
    DateTime now = new DateTime.now();
    timetablePage.fetchedDayList.add(now);
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    String startDate = now.year.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.day.toString();
    now = new DateTime.now();
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
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
      tempLessonList.add(await Lesson.fromJson(n));
    }
    tempLessonList.sort((a, b) => a.kezdetIdopont.compareTo(b.kezdetIdopont));
    int index = 0;
    if (tempLessonList != null) {
      if (tempLessonList.length != 0) {
        int beforeDay = tempLessonList[0].kezdetIdopont.day;
        //Just a matrix
        for (var n in tempLessonList) {
          if (n.kezdetIdopont.day != beforeDay) {
            index++;
            beforeDay = n.kezdetIdopont.day;
          }
          output[index].add(n);
          tempLessonListForDB.add(n);
        }
        //await batchInsertLessons(tempLessonListForDB);
      }
    }
    return output;
  }

  void setUpCalculatorPage(List<List<Evals>> input) {
    FirebaseCrashlytics.instance.log("setUpCalculatorPage");
    calculatorPage.dropdownValues = [];
    calculatorPage.dropdownValue = "";
    calculatorPage.avarageList = [];
    if (input != null && input != [[]]) {
      double sum, index;
      for (var n in input) {
        calculatorPage.dropdownValues.add(capitalize(n[0].tantargy.nev));
        sum = 0;
        index = 0;
        for (var y in n) {
          sum += y.szamErtek * y.sulySzazalekErteke / 100;
          index += 1 * y.sulySzazalekErteke / 100;
        }
        CalculatorData temp = new CalculatorData();
        temp.count = index;
        temp.sum = sum;
        calculatorPage.avarageList.add(temp);
      }
    }
    if (calculatorPage.dropdownValues.length != 0)
      calculatorPage.dropdownValue = calculatorPage.dropdownValues[0];
    else
      calculatorPage.dropdownValue = getTranslatedString("possibleNoMarks");
  }

  Future<void> getExams(token, code) async {
    FirebaseCrashlytics.instance.log("getExams");
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'User-Agent': '$agent',
      };

      var res = await http.get(
          'https://$code.e-kreta.hu/mapi/api/v1/BejelentettSzamonkeresAmi?DatumTol=null&DatumIg=null',
          headers: headers);
      if (res.statusCode != 200)
        throw Exception('get error: statusCode= ${res.statusCode}');
      if (res.statusCode == 200) {
        //print("res.body ${res.body}");
        var bodyJson = json.decode(res.body);
        examsPage.allParsedExams = await parseExams(bodyJson);
        examsPage.allParsedExams.sort((a, b) =>
            (b.datumString + b.orarendiOraOraszama.toString())
                .compareTo(a.datumString + a.orarendiOraOraszama.toString()));
        await batchInsertExams(examsPage.allParsedExams);
        //print("examsPage.allParsedExams ${examsPage.allParsedExams}");
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'getExams');
      return [];
    }
  }

//  Future<Homework> getTeacherHomework(
//       int hwId, String token, String code) async {
//     //TODO First check in database
//     FirebaseCrashlytics.instance.log("getTeacherHomework");
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     double keepForDays = prefs.getDouble("howLongKeepDataForHw");

//     var header = {
//       'Authorization': 'Bearer $token',
//       'User-Agent': '$agent',
//       'Content-Type': 'application/json',
//     };

//     var res = await http.get(
//         'https://$code.e-kreta.hu/mapi/api/v1/HaziFeladat/TanarHaziFeladat/$hwId',
//         headers: header);
//     if (res.statusCode != 200) {
//       print(res.statusCode);
//       return new Homework();
//     }
//     //Process response
//     var decoded = json.decode(res.body);
//     Homework temp = Homework.fromJson(decoded);
//     //*Add it to the database
//     await insertHomework(temp);
//     //Find the same ids
//     var matchedIds = homeworkPage.globalHomework.where((element) {
//       return element.id == temp.id;
//     });

//     //Should we keep it?
//     DateTime afterDue = temp.dueDate;
//     if (keepForDays != -1) {
//       afterDue = afterDue.add(Duration(days: keepForDays.toInt()));
//     }

//     if (matchedIds.length == 0) {
//       if (afterDue.compareTo(DateTime.now()) >= 0) {
//         homeworkPage.globalHomework.add(temp);
//       }
//     } else {
//       var matchedindex = homeworkPage.globalHomework.indexWhere((element) {
//         return element.id == temp.id;
//       });
//       if (afterDue.compareTo(DateTime.now()) >= 0) {
//         homeworkPage.globalHomework[matchedindex] = temp;
//       }
//     }
//     homeworkPage.globalHomework.sort((a, b) => a.dueDate.compareTo(b.dueDate));
//     return temp;
//   }
  //TODO Get student homework too
}
