import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:novynaplo/API/apiEndpoints.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/school.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:novynaplo/helpers/logicAndMath/parsing/parseAbsences.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseTimetable.dart';
import 'package:novynaplo/helpers/logicAndMath/setUpMarkCalculator.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/ui/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

var client = http.Client();

class RequestHandler {
  static Future<String> login(User user) async {
    FirebaseCrashlytics.instance.log("networkLoginRequest");
    try {
      var response = await client.post(
        BaseURL.KRETA_IDP + KretaEndpoints.token,
        body: {
          "userName": user.username,
          "password": user.password,
          "institute_code": user.school,
          "grant_type": "password",
          "client_id": config.clientId
        },
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "User-Agent": config.userAgent,
        },
      );

      Map responseJson = jsonDecode(response.body);

      if (responseJson["error"] != null) {
        return getTranslatedString(responseJson["error"]) +
            (response.statusCode != 200 ? " ${response.statusCode}" : "");
      } else {
        globals.userDetails.token = responseJson["access_token"];
        globals.userDetails.tokenDate = DateTime.now();
        return "OK";
      }
    } catch (e) {
      try {
        //Try the V3 header instead of our own one
        if (config.userAgent == config.defaultUserAgent) {
          config.userAgent = await getV3Header();
        }
        var response = await client.post(
          BaseURL.KRETA_IDP + KretaEndpoints.token,
          body: {
            "userName": user.username,
            "password": user.password,
            "institute_code": user.school,
            "grant_type": "password",
            "client_id": config.clientId
          },
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": config.userAgent,
          },
        );

        Map responseJson = jsonDecode(response.body);

        if (responseJson["error"] != null) {
          return getTranslatedString(responseJson["error"]) +
              (response.statusCode != 200 ? " ${response.statusCode}" : "");
        } else {
          globals.userDetails.token = responseJson["access_token"];
          globals.userDetails.tokenDate = DateTime.now();
          return "OK";
        }
      } catch (e) {
        return getTranslatedString("noAns");
      }
    }
  }

  //Get header from my api
  static Future<String> getV3Header() async {
    FirebaseCrashlytics.instance.log("getV3Header");
    var response = await client.get(
      BaseURL.NOVY_NAPLO + NovyNaploEndpoints.header,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "User-Agent": config.userAgent,
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["V3header"];
    } else {
      return config.userAgentFallback;
    }
  }

  static Future<Student> getStudentInfo() async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) + KretaEndpoints.student,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      Map responseJson = jsonDecode(response.body);
      Student student = Student.fromJson(responseJson);

      return student;
    } catch (e, s) {
      return null;
    }
  }

  static Future<List<Evals>> getEvaluations({bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) + KretaEndpoints.evaluations,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Evals> evaluations = [];

      responseJson
          .forEach((evaluation) => evaluations.add(Evals.fromJson(evaluation)));
      if (sort) {
        evaluations
            .sort((a, b) => b.rogzitesDatuma.compareTo(a.rogzitesDatuma));
      }

      return evaluations;
    } catch (e, s) {
      return null;
    }
  }

  static Future<dynamic> getSchoolList() async {
    FirebaseCrashlytics.instance.log("getSchoolList");
    List<School> tempList = [];
    var header = {
      'User-Agent': '${config.userAgent}',
      'Content-Type': 'application/json',
    };
    var response;
    try {
      response = await client
          .get(
            BaseURL.NOVY_NAPLO + NovyNaploEndpoints.schoolList,
            headers: header,
          )
          .timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      return "TIMEOUT";
    } finally {
      client.close();
    }
    if (response.statusCode != 200) {
      return response.statusCode;
    }
    List<dynamic> responseJson = json.decode(utf8.decode(response.bodyBytes));
    for (var n in responseJson) {
      tempList.add(School.fromJson(n));
    }
    return tempList;
  }

  static Future<List<List<Absence>>> getAbsencesMatrix() async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) + KretaEndpoints.absences,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Absence> absences = [];

      responseJson
          .forEach((absence) => absences.add(Absence.fromJson(absence)));
      //No need to sort, the make function has a builtin sorting function
      List<List<Absence>> outputList = await makeAbsencesMatrix(absences);
      return outputList;
    } catch (error) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getGroups() async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) + KretaEndpoints.groups,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
    } catch (error) {
      print("ERROR: KretaAPI.getGroup: " + error.toString());
      return null;
    }
  }

  //!This only throws error for now
  static Future<List> getClassAvarage(String groupId) async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) +
            KretaEndpoints.classAverages +
            "?oktatasiNevelesiFeladatUid=" +
            groupId,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      print(BaseURL.kreta(globals.userDetails.school) +
          KretaEndpoints.classAverages +
          "?oktatasiNevelesiFeladatUid=" +
          groupId);

      dynamic responseJson = jsonDecode(response.body);
      List averages = [];

      //TODO: Create class
      /*responseJson.forEach((average) {
        averages.add([
          Subject.fromJson(average["Tantargy"]),
          average["OsztalyCsoportAtlag"]
        ]);
      });*/

      return averages;
    } catch (error) {
      print("ERROR: KretaAPI.getAverages: " + error.toString());
      return null;
    }
  }

  static Future<List<Exam>> getExams({bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) + KretaEndpoints.exams,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Exam> exams = [];

      responseJson.forEach((exam) => exams.add(Exam.fromJson(exam)));
      if (sort) {
        exams.sort((a, b) => (b.datumString + b.orarendiOraOraszama.toString())
            .compareTo(a.datumString + a.orarendiOraOraszama.toString()));
      }

      return exams;
    } catch (error) {
      print("ERROR: KretaAPI.getExams: " + error.toString());
      return null;
    }
  }

  static Future<List<Homework>> getHomeworks(DateTime fromDue,
      {bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) +
            KretaEndpoints.homeworks +
            "?datumTol=" +
            fromDue.toUtc().toIso8601String(),
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Homework> homeworks = [];
      //CHECHK FOR ATTACHMENTS, because using this endpoint Kréta doesn't return it
      //You have to query every single homework
      for (var n in responseJson) {
        homeworks.add(await getHomeworkId(n['Uid']));
      }
      homeworks.sort((a, b) => a.hataridoDatuma.compareTo(b.hataridoDatuma));

      return homeworks;
    } catch (error) {
      print("ERROR: KretaAPI.getHomeworks: " + error.toString());
      return null;
    }
  }

  static Future<List<List<Lesson>>> getSpecifiedWeeksLesson(
      DateTime date) async {
    if (await NetworkHelper().isNetworkAvailable() == ConnectivityResult.none) {
      throw Exception(getTranslatedString("noNet"));
    }
    List<DateTime> days = [];
    int monday = 1;
    int sunday = 7;
    DateTime now = date;
    days.add(now);
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
      days.add(now);
    }
    DateTime startDate = now;
    now = date;
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
      days.add(now);
    }
    days.sort((a, b) => a.compareTo(b));
    DateTime endDate = now;
    bool errored = false;
    //Has builtin sorting
    List<List<Lesson>> lessonList =
        await getTimetableMatrix(startDate, endDate);
    print("Körte $lessonList");
    try {
      return lessonList;
    } catch (e) {
      print("Get Specified Week's Lessons: $e");
      errored = true;
      return [];
    } finally {
      if (!errored) {
        timetablePage.fetchedDayList.addAll(days);
      }
    }
  }

  static Future<List<List<Lesson>>> getThisWeeksLessons() async {
    int monday = 1;
    int sunday = 7;
    DateTime now = new DateTime.now();
    timetablePage.fetchedDayList.add(now);
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    DateTime startDate = now;
    now = new DateTime.now();
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    DateTime endDate = now;
    return await getTimetableMatrix(startDate, endDate);
  }

  static Future<List<List<Lesson>>> getTimetableMatrix(
      DateTime from, DateTime to) async {
    if (from == null || to == null) return [];

    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) +
            KretaEndpoints.timetable +
            "?datumTol=" +
            from.toUtc().toKretaDateString() +
            "&datumIg=" +
            to.toUtc().toKretaDateString(),
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );
      List responseJson = jsonDecode(response.body);
      List<Lesson> lessons = [];

      for (var lesson in responseJson) {
        Lesson temp = await Lesson.fromJson(lesson);
        lessons.add(temp);
      }
      //Make function has builtin sorting
      List<List<Lesson>> output = await makeTimetableMatrix(lessons);
      return output;
    } catch (error) {
      print("ERROR: KretaAPI.getLessons: " + error.toString());
      return null;
    }
  }

  static Future<List<Event>> getEvents({bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) + KretaEndpoints.events,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List<Event> events = [];

      List responseJson = jsonDecode(response.body);
      responseJson.forEach((json) => events.add(Event.fromJson(json)));
      if (sort) {
        events.sort((a, b) => b.ervenyessegVege.compareTo(a.ervenyessegVege));
      }

      return events;
    } catch (error) {
      print("ERROR: KretaAPI.getEvents " + error.toString());
      return null;
    }
  }

  static Future<List<Notice>> getNotices({bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) + KretaEndpoints.notes,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List<Notice> notes = [];

      List responseJson = jsonDecode(response.body);
      responseJson.forEach((json) => notes.add(Notice.fromJson(json)));
      if (sort) {
        notes.sort((a, b) => b.datum.compareTo(a.datum));
      }
      return notes;
    } catch (error) {
      print("ERROR: KretaAPI.getNotes: " + error.toString());
      return null;
    }
  }

  static Future<Homework> getHomeworkId(String id) async {
    if (id == null) return Homework();
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) +
            KretaEndpoints.homeworkId(id),
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      var responseJson = jsonDecode(response.body);

      Homework homework = Homework.fromJson(responseJson);

      return homework;
    } catch (error) {
      print("ERROR: KretaAPI.getHomeworks: " + error.toString());
      return null;
    }
  }

  static Future<void> getEverything() async {
    marksPage.allParsedByDate = await getEvaluations();
    examsPage.allParsedExams = await getExams();
    noticesPage.allParsedNotices = await getNotices();
    homeworkPage.globalHomework = await getHomeworks(
      DateTime.now().subtract(
        Duration(
          days: globals.howLongKeepDataForHw.toInt(),
        ),
      ),
    );
    absencesPage.allParsedAbsences = await getAbsencesMatrix();
    timetablePage.lessonsList = await getThisWeeksLessons();
    //Get stuff needed to make statistics
    statisticsPage.allParsedSubjects =
        categorizeSubjectsFromEvals(marksPage.allParsedByDate);
    statisticsPage.allParsedSubjectsWithoutZeros = List.from(
      statisticsPage.allParsedSubjects
          .where((element) => element[0].szamErtek != 0),
    );
    setUpCalculatorPage(statisticsPage.allParsedSubjects);
    eventsPage.allParsedEvents = await getEvents();
  }

  static void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  //FIXME: Make homework attachment an own function which invokes this one
  static Future<File> downloadFile(String url, String filename,
      {bool open = true}) async {
    String dir = (await getTemporaryDirectory()).path;
    String path = '$dir/temp.' + filename;
    File file = new File(path);
    print(await file.exists());
    if (await file.exists()) {
      if (open) {
        await OpenFile.open(path);
      }
      return file;
    } else {
      var response = await client.get(
        url,
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      await file.writeAsBytes(response.bodyBytes);
      if (open) {
        await OpenFile.open(path);
      }
      return file;
    }
  }
}
