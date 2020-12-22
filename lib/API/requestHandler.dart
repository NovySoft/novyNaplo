import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/API/apiEndpoints.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/data/database/evals.dart';
import 'package:novynaplo/data/database/events.dart';
import 'package:novynaplo/data/database/notices.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/school.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
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
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

var client = http.Client();

class RequestHandler {
  static Future<TokenResponse> login(Student user) async {
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
        return TokenResponse(
          status: responseJson["error_description"],
        );
      } else if (response.statusCode == 200) {
        user.token = responseJson["access_token"];
        user.tokenDate = DateTime.now();
        return TokenResponse(
          status: "OK",
          userinfo: user,
        );
      } else {
        return TokenResponse(
          status:
              "${getTranslatedString('errWhileFetch')}: ${response.statusCode}",
        );
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
          return TokenResponse(
            status: responseJson["error_description"],
          );
        } else if (response.statusCode == 200) {
          user.token = responseJson["access_token"];
          user.tokenDate = DateTime.now();
          return TokenResponse(
            status: "OK",
            userinfo: user,
          );
        } else {
          return TokenResponse(
            status:
                "${getTranslatedString('errWhileFetch')}: ${response.statusCode}",
          );
        }
      } catch (e) {
        return TokenResponse(
          status: getTranslatedString("noAns"),
        );
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

  static Future<Student> getStudentInfo(Student userDetails,
      {bool embedEncryptedDetails = false, Student encryptedDetails}) async {
    if (embedEncryptedDetails && encryptedDetails == null) {
      throw ErrorDescription("Embededable details were not given");
    }
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.student,
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      Map responseJson = jsonDecode(response.body);
      Student student = Student.fromJson(responseJson);
      if (embedEncryptedDetails) {
        student.userId = encryptedDetails.userId;
        student.iv = encryptedDetails.iv;
        student.school = encryptedDetails.school;
        student.username = encryptedDetails.username;
        student.password = encryptedDetails.password;
        student.current = encryptedDetails.current;
      }
      return student;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Evals>> getEvaluations(Student userDetails,
      {bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.evaluations,
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Evals> evaluations = [];

      responseJson.forEach(
        (evaluation) => evaluations.add(
          Evals.fromJson(
            evaluation,
            userDetails,
          ),
        ),
      );

      if (sort) {
        evaluations.sort(
          (a, b) {
            if (a.date.isSameDay(b.date)) {
              return b.createDate.compareTo(a.createDate);
            } else {
              return b.date.compareTo(a.date);
            }
          },
        );
      }
      batchInsertEvals(evaluations);
      return evaluations;
    } catch (e) {
      return null;
    }
  }

  static Future<List<School>> getSchoolList() async {
    FirebaseCrashlytics.instance.log("getSchoolList");
    try {
      var response = await client.get(
        BaseURL.NOVY_NAPLO + NovyNaploEndpoints.schoolList,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': config.userAgent,
        },
      );

      List responseJson = jsonDecode(utf8.decode(response.bodyBytes));
      List<School> schoolList = [];

      responseJson
          .forEach((absence) => schoolList.add(School.fromJson(absence)));

      return schoolList;
    } catch (error) {
      return null;
    }
  }

  static Future<List<List<Absence>>> getAbsencesMatrix(
      Student userDetails) async {
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.absences,
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
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

  static Future<List<Exam>> getExams(Student userDetails,
      {bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.exams,
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Exam> exams = [];

      responseJson.forEach((exam) => exams.add(Exam.fromJson(exam)));
      if (sort) {
        exams.sort((a, b) => (b.date.toString() + b.lessonNumber.toString())
            .compareTo(a.date.toString() + a.lessonNumber.toString()));
      }

      return exams;
    } catch (error) {
      print("ERROR: KretaAPI.getExams: " + error.toString());
      return null;
    }
  }

  static Future<List<Homework>> getHomeworks(Student userDetails,
      {@required DateTime fromDue, bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) +
            KretaEndpoints.homeworks +
            "?datumTol=" +
            fromDue.toUtc().toIso8601String(),
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Homework> homeworks = [];
      //CHECHK FOR ATTACHMENTS, because using this endpoint Kréta doesn't return it
      //You have to query every single homework, which is bullcrap but I can't change it
      for (var n in responseJson) {
        homeworks.add(await getHomeworkId(userDetails, id: n['Uid']));
      }
      homeworks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      return homeworks;
    } catch (error) {
      print("ERROR: KretaAPI.getHomeworks: " + error.toString());
      return null;
    }
  }

  static Future<List<List<Lesson>>> getSpecifiedWeeksLesson(Student userDetails,
      {DateTime date}) async {
    if (!(await NetworkHelper.isNetworkAvailable())) {
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
    List<List<Lesson>> lessonList = await getTimetableMatrix(
      userDetails,
      from: startDate,
      to: endDate,
    );
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

  static Future<List<List<Lesson>>> getThisWeeksLessons(
      Student userDetails) async {
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
    return await getTimetableMatrix(
      userDetails,
      from: startDate,
      to: endDate,
    );
  }

  static Future<List<List<Lesson>>> getTimetableMatrix(Student userDetails,
      {@required DateTime from, @required DateTime to}) async {
    if (from == null || to == null) return [];

    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) +
            KretaEndpoints.timetable +
            "?datumTol=" +
            from.toUtc().toDayOnlyString() +
            "&datumIg=" +
            to.toUtc().toDayOnlyString(),
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );
      List responseJson = jsonDecode(response.body);
      List<Lesson> lessons = [];

      for (var lesson in responseJson) {
        Lesson temp = Lesson.fromJson(lesson);
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

  static Future<List<Event>> getEvents(Student userDetails,
      {bool sort = true}) async {
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.events,
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List<Event> events = [];

      List responseJson = jsonDecode(response.body);
      responseJson.forEach(
        (json) => events.add(
          Event.fromJson(
            json,
            userDetails,
          ),
        ),
      );
      if (sort) {
        events.sort((a, b) => b.endDate.compareTo(a.endDate));
      }
      batchInsertEvents(events);
      return events;
    } catch (error) {
      print("ERROR: KretaAPI.getEvents " + error.toString());
      return null;
    }
  }

  static Future<List<Notice>> getNotices(
    Student userDetails, {
    bool sort = true,
  }) async {
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.notes,
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List<Notice> notes = [];

      List responseJson = jsonDecode(response.body);
      responseJson.forEach(
        (json) => notes.add(
          Notice.fromJson(
            json,
            userDetails,
          ),
        ),
      );

      if (sort) {
        notes.sort((a, b) => b.date.compareTo(a.date));
      }

      batchInsertNotices(notes);
      return notes;
    } catch (error) {
      print("ERROR: KretaAPI.getNotes: " + error.toString());
      return null;
    }
  }

  static Future<Homework> getHomeworkId(Student userDetails,
      {String id}) async {
    if (id == null) return Homework();
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.homeworkId(id),
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
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

  static Future<void> getEverything(
    Student user, {
    bool setData = false,
  }) async {
    marksPage.allParsedByDate = await getEvaluations(user);
    examsPage.allParsedExams = await getExams(user);
    noticesPage.allParsedNotices = await getNotices(user);
    homeworkPage.globalHomework = await getHomeworks(
      user,
      fromDue: DateTime.now().subtract(
        Duration(
          days: globals.howLongKeepDataForHw.toInt(),
        ),
      ),
    );
    absencesPage.allParsedAbsences = await getAbsencesMatrix(user);
    timetablePage.lessonsList = await getThisWeeksLessons(user);
    //Get stuff needed to make statistics
    statisticsPage.allParsedSubjects =
        categorizeSubjectsFromEvals(marksPage.allParsedByDate);
    statisticsPage.allParsedSubjectsWithoutZeros = List.from(
      statisticsPage.allParsedSubjects
          .where((element) => element[0].numberValue != 0),
    );
    setUpCalculatorPage(statisticsPage.allParsedSubjects);
    eventsPage.allParsedEvents = await getEvents(user);
  }

  static void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static Future<File> downloadHWAttachment(Student userDetails,
      {Attachment hwInfo}) async {
    File file = await downloadFile(
      userDetails,
      url: BaseURL.kreta(userDetails.school) +
          KretaEndpoints.downloadHomeworkCsatolmany(hwInfo.uid, hwInfo.type),
      filename: hwInfo.uid + "." + hwInfo.name,
    );
    return file;
  }

  static Future<File> downloadFile(Student userDetails,
      {String url, String filename, bool open = true}) async {
    String dir = (await getTemporaryDirectory()).path;
    String path = '$dir/temp.' + filename;
    File file = new File(path);
    if (await file.exists()) {
      if (open) {
        await OpenFile.open(path);
      }
      return file;
    } else {
      var response = await client.get(
        url,
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
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
