import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/API/apiEndpoints.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/github.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/kretaCert.dart';
import 'package:novynaplo/data/models/kretaNonce.dart';
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
import 'package:novynaplo/helpers/misc/decodeJwt.dart';
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
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'calcKretaNonce.dart';

var client = http.Client();
bool isError = false;

class RequestHandler {
  static Future<GitHubReleaseInfo> getLatestGitVer() async {
    var response = await client.get(
      Uri.parse(
        BaseURL.NOVY_NAPLO_GITHUB_REPO + GitHubApiEndpoints.getLatestVersion,
      ),
      headers: {
        "User-Agent": config.userAgent,
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      return GitHubReleaseInfo.fromJson(responseJson);
    }
    return GitHubReleaseInfo(
      tagName: config.currentAppVersionCode,
    );
  }

  static Future<GitHubReleaseInfo> getLatestPreGitVer() async {
    var response = await client.get(
      Uri.parse(
        BaseURL.NOVY_NAPLO_GITHUB_REPO + GitHubApiEndpoints.getReleases(),
      ),
      headers: {
        "User-Agent": config.userAgent,
      },
    );
    if (response.statusCode == 200) {
      List responseJson = jsonDecode(response.body);
      List<GitHubReleaseInfo> releases = [];
      for (var item in responseJson) {
        releases.add(GitHubReleaseInfo.fromJson(item));
      }
      GitHubReleaseInfo latestPrev = releases.firstWhere(
        (element) => element.preRelease,
      );
      return latestPrev;
    }
    return GitHubReleaseInfo(
      tagName: config.currentAppVersionCode,
    );
  }

  static Future<KretaNonce> getNonce(Student userDetails) async {
    try {
      FirebaseCrashlytics.instance.log("getNonce");

      var result = await client.get(
        Uri.parse(BaseURL.KRETA_IDP + IDPEndpoints.nonce),
        headers: {
          "User-Agent": config.userAgent,
        },
      );

      return new KretaNonce(
        nonce: result.body,
        key: calculateKretaNonceKey(userDetails, result.body),
        version: "v2",
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getNonce',
        printDetails: true,
      );
      return new KretaNonce(
        version: "v1",
      );
    }
  }

  static Future<List<KretaCert>> getKretaTrustedCerts() async {
    try {
      FirebaseCrashlytics.instance.log("getKretaTrustedCerts");
      print("Updating trusted certificates");

      var result = await client.get(
        Uri.parse(BaseURL.NOVY_NAPLO + NovyNaploEndpoints.certificates),
        headers: {
          "User-Agent": config.userAgent,
        },
      ).timeout(Duration(seconds: 30), onTimeout: () {
        return http.Response("Timeout", 408);
      });

      if (result.statusCode == 200) {
        List responseJson = jsonDecode(result.body);
        List<KretaCert> output = [];

        for (var cert in responseJson) {
          output.add(new KretaCert(
            radixModulus: cert['radixModulus'],
            exponent: cert['exponent'],
            subject: cert['subject'],
          ));
          print(cert['subject']);
        }

        DatabaseHelper.setTrustedCerts(output);
        return output;
      } else {
        return [];
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getKretaTrustedCerts',
        printDetails: true,
      );
      return [];
    }
  }

  static Future<bool> checkForKretaUpdatingStatus(
    Student userDetails, {
    bool retry = false,
  }) async {
    FirebaseCrashlytics.instance.log("checkForKretaUpdatingStatus");
    //!Important
    /*
    Always check the school site for updating as the school site handles the data and 
    the IDP server is completly independent from the school site. This means that the idp maybe working, but
    the school site can be offline at the same time
    */
    try {
      var response = await client.get(
        Uri.parse(BaseURL.kreta(userDetails.school) + KretaEndpoints.webLogin),
        headers: {
          "User-Agent": config.userAgent,
        },
      ).timeout(Duration(seconds: 30), onTimeout: () {
        return http.Response("Timeout", 408);
      });

      if (response.statusCode != 200) {
        if (retry) {
          bool isKretaUpdating = await checkForKretaUpdatingStatus(
            userDetails,
            retry: false,
          );
          return isKretaUpdating;
        }
        print("FRISSÍT");
        printWrapped(response.body);
        print(response.statusCode);
        FirebaseAnalytics.instance.logEvent(
          name: "KretaUpdating",
        );
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

   //DEPRECATED
   /* static Future<TokenResponse> login(Student user) async {
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

      KretaNonce nonce = await getNonce(user);

      var response = await client.post(
        Uri.parse(BaseURL.KRETA_IDP + IDPEndpoints.token),
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
          "X-AuthorizationPolicy-Nonce": nonce.nonce,
          "X-AuthorizationPolicy-Key": nonce.key,
          "X-AuthorizationPolicy-Version": nonce.version
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
  } */

  static Future<Student> getStudentInfo(
    Student userDetails, {
    bool embedDetails = false,
  }) async {
    FirebaseCrashlytics.instance.log("getStudentInfo");
    try {
      var response = await client.get(
        Uri.parse(BaseURL.kreta(userDetails.school) + KretaEndpoints.student),
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      Map responseJson = jsonDecode(response.body);
      Student student = Student.fromJson(responseJson);

      if (embedDetails) {
        student.userId = userDetails.userId;
        student.school = userDetails.school;
        student.username = userDetails.username;
        student.current = userDetails.current;
        student.refreshToken = userDetails.refreshToken;
        student.tokenDate = userDetails.tokenDate;
        student.token = userDetails.token;
      } else {
        student.userId = userDetails.userId;
        await DatabaseHelper.updateKretaGivenParameters(student);
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
    Student userDetails,
    Map<String, double> classAverages, {
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getEvaluations");
    try {
      var response = await client.get(
        Uri.parse(
            BaseURL.kreta(userDetails.school) + KretaEndpoints.evaluations),
        headers: {
          "Authorization": "Bearer ${userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Evals> evaluations = [];

      for (var evaluation in responseJson) {
        Evals temp = Evals.fromJson(
          evaluation,
          userDetails,
        );
        double tempAv;
        if (userDetails.institution.customizationOptions.canViewClassAV) {
          tempAv = await DatabaseHelper.getEvalAssocedClassAv(
            temp.userId,
            temp.uid,
          );
          if (tempAv == null &&
              temp.createDate.difference(DateTime.now()).inDays >= -7 &&
              classAverages != null) {
            tempAv = classAverages[temp.subject.uid];
          }
        }
        temp.classAv = tempAv;
        evaluations.add(
          temp,
        );
      }

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
      DatabaseHelper.batchInsertEvals(evaluations, userDetails);
      return evaluations;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getEvaluations',
        printDetails: true,
      );
      isError = true;
      return marksPage.allParsedByDate;
    }
  }

  static Future<List<School>> getSchoolList() async {
    FirebaseCrashlytics.instance.log("getSchoolList");
    try {
      var response = await client.get(
        Uri.parse(BaseURL.NOVY_NAPLO + NovyNaploEndpoints.schoolList),
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
        Uri.parse(BaseURL.kreta(userDetails.school) + KretaEndpoints.absences),
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
      DatabaseHelper.batchInsertAbsences(absences, userDetails);
      return outputList;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getAbsencesMatrix',
        printDetails: true,
      );
      isError = true;
      return absencesPage.allParsedAbsences;
    }
  }

  static Future<List<Exam>> getExams(
    Student userDetails, {
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getExams");
    try {
      var response = await client.get(
        Uri.parse(BaseURL.kreta(userDetails.school) + KretaEndpoints.exams),
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
        exams.sort((a, b) => (b.dateOfWriting.toDayOnlyString() +
                b.lessonNumber.toString())
            .compareTo(
                a.dateOfWriting.toDayOnlyString() + a.lessonNumber.toString()));
      }
      DatabaseHelper.batchInsertExams(
        exams,
        userDetails,
      );
      return exams;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getExams',
        printDetails: true,
      );
      isError = true;
      return examsPage.allParsedExams;
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
        Uri.parse(BaseURL.kreta(userDetails.school) +
            KretaEndpoints.homeworks +
            "?datumTol=" +
            fromDue.toUtc().toIso8601String()),
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
      homeworks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      DatabaseHelper.batchInsertHomework(homeworks, userDetails);
      return homeworks;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getHomeworks',
        printDetails: true,
      );
      isError = true;
      return homeworkPage.globalHomework;
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
      if ((userDetails.tokenDate ?? DateTime(1970)).isBefore(
        DateTime.now().subtract(
          Duration(
            minutes: 25,
          ),
        ),
      )) {
        TokenResponse res = await loginWRefresh(userDetails);
        if (res.status == "OK") {
          if (userDetails.current) {
            globals.currentUser.token = res.userinfo.token;
            globals.currentUser.tokenDate = res.userinfo.tokenDate;
          }
          userDetails.token = res.userinfo.token;
          userDetails.tokenDate = res.userinfo.tokenDate;
        }
      }
      //Has builtin sorting
      List<List<Lesson>> lessonList = await getTimetableMatrix(
        userDetails,
        from: startDate,
        to: endDate,
      );

      if (lessonList == null) {
        errored = true;
        return [];
      }

      return lessonList;
    } catch (e, s) {
      print("Get Specified Week's Lessons: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getSpecifiedWeeksLesson',
        printDetails: true,
      );
      isError = true;
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
    try {
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
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getThreeWeeksLessons',
        printDetails: true,
      );
      isError = true;
      return timetablePage.lessonsList;
    }
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
        Uri.parse(BaseURL.kreta(userDetails.school) +
            KretaEndpoints.timetable +
            "?datumTol=" +
            from.toUtc().toDayOnlyString() +
            "&datumIg=" +
            to.toUtc().toDayOnlyString()),
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
        userDetails,
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
        Uri.parse(BaseURL.kreta(userDetails.school) + KretaEndpoints.events),
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
      DatabaseHelper.batchInsertEvents(events, userDetails);
      return events;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getEvents',
        printDetails: true,
      );
      isError = true;
      return eventsPage.allParsedEvents;
    }
  }

  static Future<List<Notice>> getNotices(
    Student userDetails, {
    bool sort = true,
  }) async {
    FirebaseCrashlytics.instance.log("getNotices");
    try {
      var response = await client.get(
        Uri.parse(BaseURL.kreta(userDetails.school) + KretaEndpoints.notes),
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
      DatabaseHelper.batchInsertNotices(notes, userDetails);
      return notes;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getNotices',
        printDetails: true,
      );
      isError = true;
      return noticesPage.allParsedNotices;
    }
  }

  static Future<Homework> getHomeworkId(
    Student inputUserDetails, {
    @required String id,
    bool isStandAloneCall = false,
  }) async {
    Student userDetails = inputUserDetails;
    FirebaseCrashlytics.instance.log("getHomeworkId");
    if (id == null) return Homework();
    if (isStandAloneCall == true) {
      if (inputUserDetails == null) {
        inputUserDetails = Student();
        inputUserDetails.userId = await DatabaseHelper.getHomeworkUser(id);
      }
      userDetails = await DatabaseHelper.getUserById(inputUserDetails.userId);
      userDetails.token = globals.allUsers
          .firstWhere(
            (element) => element.userId == inputUserDetails.userId,
            orElse: () => null,
          )
          ?.token;
    }
    if (userDetails.token == null) {
      if (userDetails.userId != null) {
        if (globals.currentUser.name == userDetails.name &&
            globals.currentUser.token != null) {
          userDetails.token = globals.currentUser.token;
        } else {
          TokenResponse temp = await RequestHandler.loginWRefresh(userDetails);
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
        Uri.parse(
            BaseURL.kreta(userDetails.school) + KretaEndpoints.homeworkId(id)),
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
        DatabaseHelper.insertHomework(homework, userDetails);
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

  ///Returns true on failure
  static Future<bool> getEverything(
    Student user, {
    bool setData = false,
  }) async {
    FirebaseCrashlytics.instance.log("getEverything");
    isError = false;
    user = await getStudentInfo(user, embedDetails: true);
    if (setData) {
      statisticsPage.classAverages = await getClassAverages(user);
      //FIXME: Something not right with embeding the classAV!
      marksPage.allParsedByDate = await getEvaluations(
        user,
        statisticsPage.classAverages,
      );
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
      //Get stuff needed to make statistics (this removes percent marks if necessary)
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
        statisticsPage.classAverages,
      );
    } else {
      Map<String, double> tempClassAverages = await getClassAverages(user);
      List<Evals> tempEvals = await getEvaluations(
        user,
        tempClassAverages,
      );
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
        tempClassAverages,
      );
    }
    return isError;
  }

  static void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static Future<File> downloadHWAttachment(
    Student userDetails, {
    Attachment hwInfo,
  }) async {
    if (userDetails.tokenDate.isBefore(
      DateTime.now().subtract(
        Duration(
          minutes: 25,
        ),
      ),
    )) {
      TokenResponse res = await loginWRefresh(userDetails);
      if (res.status == "OK") {
        if (userDetails.current) {
          globals.currentUser.token = res.userinfo.token;
          globals.currentUser.tokenDate = res.userinfo.tokenDate;
        }
        userDetails.token = res.userinfo.token;
        userDetails.tokenDate = res.userinfo.tokenDate;
      }
    }
    File file = await downloadFile(
      userDetails: userDetails,
      url: BaseURL.kreta(userDetails.school) +
          KretaEndpoints.downloadHomeworkCsatolmany(hwInfo.uid, hwInfo.type),
      filename: hwInfo.uid + "." + hwInfo.name,
      sendKretaAuth: true,
    );
    return file;
  }

  static Future<File> downloadFile({
    Student userDetails,
    String url,
    String filename,
    bool open = true,
    bool sendKretaAuth = false,
    bool reDownload = false,
  }) async {
    String dir = (await getTemporaryDirectory()).path;
    String path = '$dir/temp.' + filename;
    File file = new File(path);

    print("DEBUG: File access: $path (${file.path})");

    if (await file.exists() && !reDownload) {
      if (open) {
        await OpenFilex.open(path);
      }
      return file;
    } else {
      Map<String, String> headerMap = {
        "User-Agent": config.userAgent,
      };
      if (sendKretaAuth) {
        headerMap["Authorization"] = "Bearer ${userDetails.token}";
      }

      print("DEBUG: Downloading file from $url");

      var response = await client.get(
        Uri.parse(url),
        headers: headerMap,
      );

      print("DEBUG: Downloaded ${response.bodyBytes.length} bytes");

      await file.writeAsBytes(response.bodyBytes);

      print("DEBUG: Wrote ${response.bodyBytes.length} bytes");

      if (open) {
        print("DEBUG: Opening $path");
        await OpenFilex.open(path);
        print("DEBUG: Opened $path");
      }
      return file;
    }
  }

  static Future<String> getClassGroupUid(Student user) async {
    try {
      var response = await client.get(
        Uri.parse(
          BaseURL.kreta(user.school) + KretaEndpoints.groups,
        ),
        headers: {
          "Authorization": "Bearer ${user.token}",
          "User-Agent": config.userAgent,
        },
      );
      var responseJson = jsonDecode(response.body);
      return responseJson[0]["OktatasNevelesiFeladat"]["Uid"];
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getClassGroupUid',
        printDetails: true,
      );
      isError = true;
      return "";
    }
  }

  static Future<Map<String, double>> getClassAverages(Student user) async {
    try {
      if (user.institution.customizationOptions.canViewClassAV != true) {
        return {};
      }

      FirebaseCrashlytics.instance.log("getClassAverages");
      Map<String, double> output = {};
      String mainGroup = await RequestHandler.getClassGroupUid(user);
      var response = await client.get(
        Uri.parse(
          BaseURL.kreta(user.school) +
              KretaEndpoints.classAverages +
              "?oktatasiNevelesiFeladatUid=" +
              mainGroup,
        ),
        headers: {
          "Authorization": "Bearer ${user.token}",
          "User-Agent": config.userAgent,
        },
      );
      var responseJson = jsonDecode(response.body);

      for (var item in responseJson) {
        output[item["Uid"]] = item["OsztalyCsoportAtlag"];
      }

      return output;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'getClassAverages',
        printDetails: true,
      );
      isError = true;
      return statisticsPage.classAverages;
    }
  }

  static Future<TokenResponse> newLogin(String code) async {
    try {
      FirebaseCrashlytics.instance.log("newLogin");

      var response = await client.post(
        Uri.parse(BaseURL.KRETA_IDP + IDPEndpoints.token),
        body: {
          "code": code,
          "code_verifier": "DSpuqj_HhDX4wzQIbtn8lr8NLE5wEi1iVLMtMK0jY6c",
          "redirect_uri":
              "https://mobil.e-kreta.hu/ellenorzo-student/prod/oauthredirect",
          "client_id": config.clientId,
          "grant_type": "authorization_code",
        },
        headers: {
          "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
          "accept": "*/*",
          "user-agent": config.userAgent,
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
        Student user = Student();
        user.token = responseJson["access_token"];
        user.tokenDate = DateTime.now();
        user.refreshToken = responseJson["refresh_token"];
        user.school =
            JWT.parseJwt(responseJson["access_token"])["kreta:institute_code"];
        user.username =
            JWT.parseJwt(responseJson["access_token"])["kreta:user_name"];
        await DatabaseHelper.updateToken(user);
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
        reason: 'newLogin',
        printDetails: true,
      );
      return TokenResponse(
        status: "${getTranslatedString('unkError')}: \n $e",
      );
    }
  }

  static Future<TokenResponse> loginWRefresh(Student user) async {
    try {
      FirebaseCrashlytics.instance.log("loginWRefresh");

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
        Uri.parse(BaseURL.KRETA_IDP + IDPEndpoints.token),
        body: {
          "refresh_token": user.refreshToken,
          "institute_code": user.school,
          "client_id": config.clientId,
          "grant_type": "refresh_token",
          "refresh_user_data": "false",
        },
        headers: {
          "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
          "accept": "*/*",
          "user-agent": config.userAgent,
        },
      );

      Map responseJson = jsonDecode(response.body);

      if (responseJson["error"] != null ||
          responseJson["error_description"] != null) {
        // if (res["error"] == "invalid_grant")  // <-- token expired, probably, it returns this error every time
        return TokenResponse(
          status: responseJson["error_description"] != null
              ? responseJson["error_description"]
              : responseJson["error"],
        );
      } else if (response.statusCode == 200) {
        // This a refresh login, we should have the user's data already
        user.token = responseJson["access_token"];
        user.tokenDate = DateTime.now();
        user.refreshToken = responseJson["refresh_token"];
        user.school =
            JWT.parseJwt(responseJson["access_token"])["kreta:institute_code"];
        user.username =
            JWT.parseJwt(responseJson["access_token"])["kreta:user_name"];
        await DatabaseHelper.updateToken(user);

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
        reason: 'loginWRefresh',
        printDetails: true,
      );
      return TokenResponse(
        status: "${getTranslatedString('unkError')}: \n $e",
      );
    }
  }
}
