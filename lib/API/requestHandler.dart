import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:novynaplo/API/apiEndpoints.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/school.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

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

  static Future<List<Evals>> getEvaluations() async {
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

  static Future<List<Absence>> getAbsences() async {
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

      return absences;
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

  static Future<List<Exam>> getExams() async {
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

      return exams;
    } catch (error) {
      print("ERROR: KretaAPI.getExams: " + error.toString());
      return null;
    }
  }

  static Future<List<Homework>> getHomeworks(DateTime from) async {
    try {
      var response = await client.get(
        BaseURL.kreta(globals.userDetails.school) +
            KretaEndpoints.homeworks +
            "?datumTol=" +
            from.toUtc().toIso8601String(),
        headers: {
          "Authorization": "Bearer ${globals.userDetails.token}",
          "User-Agent": config.userAgent,
        },
      );

      List responseJson = jsonDecode(response.body);
      List<Homework> homeworks = [];
      printWrapped(json.encode(responseJson));

      /*responseJson
          .forEach((homework) => homeworks.add(Homework.fromJson(homework)));

      return homeworks;*/
    } catch (error) {
      print("ERROR: KretaAPI.getHomeworks: " + error.toString());
      return null;
    }
  }

  static void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
