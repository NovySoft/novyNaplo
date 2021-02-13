import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:novynaplo/API/apiEndpoints.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/data/database/databaseHelper.dart';
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
import 'package:novynaplo/helpers/logicAndMath/getMarksWithChanges.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseAbsences.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseTimetable.dart';
import 'package:novynaplo/helpers/logicAndMath/setUpMarkCalculator.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
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
  static Future<bool> checkForKretaUpdatingStatus(
    Student userDetails, {
    bool retry = false,
  }) async {
    FirebaseCrashlytics.instance.log("checkForKretaUpdatingStatus");
    //!Important
    /*
    Always check the school site for updating as the school site handles the data and 
    the IDP server is completly independent from the school site. This means that the idp maybe working, but
    the school site can be offline at the same time*/
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.webLogin,
        headers: {
          "User-Agent": config.userAgent,
        },
      ).timeout(Duration(seconds: 30), onTimeout: () {
        //FIXME: Valami nem ok, néha timeoutol
        return http.Response("Timeout", 408);
      });

      if (response.statusCode != 200) {
        print("FRISSÍT");
        printWrapped(response.body);
        print(response.statusCode);
        FirebaseAnalytics().logEvent(
          name: "KretaUpdating",
        );
        if (retry) {
          bool isKretaUpdating = await checkForKretaUpdatingStatus(
            userDetails,
            retry: false,
          );
          return isKretaUpdating;
        }
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'checkForKretaUpdatingStatus',
        printDetails: true,
      );
      return false;
    }
  }

  static Future<TokenResponse> login(Student user) async {
    FirebaseCrashlytics.instance.log("networkLoginRequest");
    try {
      //First check for kreta status then continue loging in
      bool isKretaUpdating = await checkForKretaUpdatingStatus(
        user,
        retry: true,
      );
      if (isKretaUpdating) {
        return TokenResponse(
          status:
              "${getTranslatedString('errWhileFetch')}:\n${getTranslatedString('kretaUpgrade')}",
        );
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

      if (responseJson["error"] != null ||
          responseJson["error_description"] != null) {
        return TokenResponse(
          status: responseJson["error_description"] != null
              ? responseJson["error_description"]
              : responseJson["error"],
        );
      } else if (response.statusCode == 200) {
        user.token = responseJson["access_token"];
        user.tokenDate = DateTime.now();
        return TokenResponse(
          status: "OK",
          userinfo: user,
        );
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 500 ||
          response.statusCode == 502 ||
          response.statusCode == 503) {
        //Kreta IDP is probably updating
        return TokenResponse(
          status:
              "${getTranslatedString('errWhileFetch')}: ${response.statusCode} \n ${getTranslatedString('kretaUpgradeOrWrongCred')}",
        );
      } else {
        return TokenResponse(
          status:
              "${getTranslatedString('errWhileFetch')}: ${response.statusCode}",
        );
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'login',
        printDetails: true,
      );
      return TokenResponse(
        status: "${getTranslatedString('unkError')}: \n $e",
      );
    }
  }

  static Future<Student> getStudentInfo(
    Student userDetails, {
    bool embedEncryptedDetails = false,
    Student encryptedDetails,
  }) async {
    FirebaseCrashlytics.instance.log("getStudentInfo");
    if (embedEncryptedDetails && encryptedDetails == null) {
      throw ErrorDescription("Encrypted details were not given");
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
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getStudentInfo',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<List<Evals>> getEvaluations(
    Student userDetails, {
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getEvaluations");
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
      DatabaseHelper.batchInsertEvals(evaluations);
      return evaluations;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getEvaluations',
        printDetails: true,
      );
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
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getSchoolList',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<List<List<Absence>>> getAbsencesMatrix(
    Student userDetails,
  ) async {
    FirebaseCrashlytics.instance.log("getAbsencesMatrix");
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

      responseJson.forEach(
        (absence) => absences.add(
          Absence.fromJson(
            absence,
            userDetails,
          ),
        ),
      );
      //No need to sort, the make function has a builtin sorting function
      List<List<Absence>> outputList = await makeAbsencesMatrix(absences);
      DatabaseHelper.batchInsertAbsences(absences);
      return outputList;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getAbsencesMatrix',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<List<Exam>> getExams(
    Student userDetails, {
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getExams");
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

      responseJson.forEach(
        (exam) => exams.add(
          Exam.fromJson(
            exam,
            userDetails,
          ),
        ),
      );
      if (sort) {
        exams.sort((a, b) => (b.dateOfWriting.toString() +
                b.lessonNumber.toString())
            .compareTo(a.dateOfWriting.toString() + a.lessonNumber.toString()));
      }
      DatabaseHelper.batchInsertExams(
        exams,
      );
      return exams;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getExams',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<List<Homework>> getHomeworks(
    Student userDetails, {
    @required DateTime fromDue,
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getHomeworks");
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
      //CHECK FOR ATTACHMENTS, because using this endpoint Kréta doesn't return it
      //You have to query every single homework, which is bullcrap but I can't change it
      for (var n in responseJson) {
        homeworks.add(await getHomeworkId(userDetails, id: n['Uid']));
      }
      homeworks.removeWhere((element) => element == null);
      homeworks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      DatabaseHelper.batchInsertHomework(homeworks);
      return homeworks;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getHomeworks',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<List<List<Lesson>>> getSpecifiedWeeksLesson(
    Student userDetails, {
    DateTime date,
  }) async {
    bool errored = false;
    List<DateTime> days = [];
    try {
      FirebaseCrashlytics.instance.log("getSpecifiedWeeksLesson");
      if (!(await NetworkHelper.isNetworkAvailable())) {
        throw Exception(getTranslatedString("noNet"));
      }
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
      //Has builtin sorting
      List<List<Lesson>> lessonList = await getTimetableMatrix(
        userDetails,
        from: startDate,
        to: endDate,
      );

      return lessonList;
    } catch (e, s) {
      print("Get Specified Week's Lessons: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getSpecifiedWeeksLesson',
        printDetails: true,
      );
      errored = true;
      return [];
    } finally {
      if (!errored) {
        timetablePage.fetchedDayList.addAll(days);
      }
    }
  }

  static Future<List<List<Lesson>>> getThreeWeeksLessons(
    Student userDetails,
  ) async {
    FirebaseCrashlytics.instance.log("getThreeWeeksLessons");
    int monday = 1;
    int sunday = 7;
    DateTime now = new DateTime.now();
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
    }
    DateTime startDate = now.subtract(Duration(days: 7));
    now = new DateTime.now();
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
    }
    DateTime endDate = now.add(Duration(days: 7));
    now = startDate;
    while (!now.isSameDay(endDate)) {
      timetablePage.fetchedDayList.add(now);
      now = now.add(new Duration(days: 1));
    }
    timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    return await getTimetableMatrix(
      userDetails,
      from: startDate,
      to: endDate,
    );
  }

  static Future<List<List<Lesson>>> getTimetableMatrix(
    Student userDetails, {
    @required DateTime from,
    @required DateTime to,
  }) async {
    FirebaseCrashlytics.instance.log("getTimetableMatrix");
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
        Lesson temp = Lesson.fromJson(
          lesson,
          userDetails,
        );
        lessons.add(temp);
      }
      //Make function has builtin sorting
      List<List<Lesson>> output = await makeTimetableMatrix(lessons);
      DatabaseHelper.batchInsertLessons(
        lessons,
        lookAtDate: true,
      );
      return output;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getTimetableMatrix',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<List<Event>> getEvents(
    Student userDetails, {
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getEvents");
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
      DatabaseHelper.batchInsertEvents(events);
      return events;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getEvents',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<List<Notice>> getNotices(
    Student userDetails, {
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getNotices");
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
      DatabaseHelper.batchInsertNotices(notes);
      return notes;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getNotices',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<Homework> getHomeworkId(
    Student userDetails, {
    @required String id,
    bool isStandAloneCall = false,
  }) async {
    FirebaseCrashlytics.instance.log("getHomeworkId");
    if (id == null) return Homework();
    if (userDetails.token == null) {
      if (userDetails.userId != null) {
        if (globals.currentUser.name == userDetails.name &&
            globals.currentUser.token != null) {
          userDetails.token = globals.currentUser.token;
        } else {
          TokenResponse temp = await RequestHandler.login(userDetails);
          if (temp.status == "OK") {
            userDetails = temp.userinfo;
            if (userDetails.current) {
              globals.currentUser.token = userDetails.token;
            }
          } else {
            return Homework();
          }
        }
      } else {
        return Homework();
      }
    }
    try {
      var response = await client.get(
        BaseURL.kreta(userDetails.school) + KretaEndpoints.homeworkId(id),
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );
      var responseJson = jsonDecode(response.body);

      Homework homework = Homework.fromJson(
        responseJson,
        userDetails,
      );
      if (isStandAloneCall) {
        //This function is also called when we can't found a homework attached to a lesson, and if we found it we bsave
        DatabaseHelper.insertHomework(homework);
      }
      return homework;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getHomeworkId',
        printDetails: true,
      );
      return null;
    }
  }

  static Future<void> getEverything(
    Student user, {
    bool setData = false,
  }) async {
    FirebaseCrashlytics.instance.log("getEverything");
    if (setData) {
      marksPage.allParsedByDate = await getEvaluations(user);
      examsPage.allParsedExams = await getExams(user);
      noticesPage.allParsedNotices = await getNotices(user);
      homeworkPage.globalHomework = await getHomeworks(
        user,
        fromDue: DateTime.now().subtract(
          Duration(
            days: 31,
          ),
        ),
      );
      absencesPage.allParsedAbsences = await getAbsencesMatrix(user);
      timetablePage.lessonsList = await getThreeWeeksLessons(user);
      //Get stuff needed to make statistics
      statisticsPage.allParsedSubjects =
          categorizeSubjectsFromEvals(marksPage.allParsedByDate);
      statisticsPage.allParsedSubjectsWithoutZeros = List.from(
        statisticsPage.allParsedSubjects
            .where((element) => element[0].numberValue != 0),
      );
      statisticsPage.allParsedSubjectsWithoutZeros.sort(
        (a, b) => a[0].sortIndex.compareTo(b[0].sortIndex),
      );
      setUpCalculatorPage(statisticsPage.allParsedSubjects);
      eventsPage.allParsedEvents = await getEvents(user);
      await onlyCalcAndInsertAverages(
        statisticsPage.allParsedSubjectsWithoutZeros,
        user,
      );
    } else {
      List<Evals> tempEvals = await getEvaluations(user);
      await getExams(user);
      await getNotices(user);
      await getHomeworks(
        user,
        fromDue: DateTime.now().subtract(
          Duration(
            days: 31,
          ),
        ),
      );
      await getAbsencesMatrix(user);
      await getThreeWeeksLessons(user);
      await getEvents(user);
      await onlyCalcAndInsertAverages(
        List.from(categorizeSubjectsFromEvals(tempEvals))
            .where(
              (element) => element[0].numberValue != 0,
            )
            .toList()
            .cast<List<Evals>>(),
        user,
      );
    }
    if (globals.notifications && user.fetched) {
      await NotificationDispatcher.dispatchNotifications();
    } else {
      //Clear the notification list if we are not sending it -> otherwise the next time it will send them.
      NotificationDispatcher.toBeDispatchedNotifications =
          ToBeDispatchedNotifications();
    }
  }

  static void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static Future<File> downloadHWAttachment(
    Student userDetails, {
    Attachment hwInfo,
  }) async {
    File file = await downloadFile(
      userDetails,
      url: BaseURL.kreta(userDetails.school) +
          KretaEndpoints.downloadHomeworkCsatolmany(hwInfo.uid, hwInfo.type),
      filename: hwInfo.uid + "." + hwInfo.name,
    );
    return file;
  }

  static Future<File> downloadFile(
    Student userDetails, {
    String url,
    String filename,
    bool open = true,
  }) async {
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
