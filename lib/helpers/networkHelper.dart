import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/screens/avarages_tab.dart' as avaragesPage;
import 'package:novynaplo/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:novynaplo/config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:novynaplo/functions/utils.dart';

String agent = config.currAgent;
var response;
int tokenIndex = 0;

class NetworkHelper {
  Future<ConnectivityResult> isNetworkAvailable() async {
    return await (Connectivity().checkConnectivity());
  }

  Future<String> getToken(code, user, pass) async {
    tokenIndex++;
    try {
      if (code == "" || user == "" || pass == "") {
        return "Hiányzó bemenet";
      } else {
        var headers = {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          'User-Agent': '$agent',
        };

        var data =
            'institute_code=$code&userName=$user&password=$pass&grant_type=password&client_id=919e0c1c-76a2-4646-a2fb-7085bbbf3c56';
        try {
          response = await http.post(
              'https://$code.e-kreta.hu/idp/api/v1/Token',
              headers: headers,
              body: data);
          if (response.statusCode == 200) {
            var parsedJson = json.decode(response.body);
            var status = parsedJson['token_type'];
            if (status == '' || status == null) {
              if (parsedJson["error_description"] == '' ||
                  parsedJson["error_description"] == null) {
                return "Hibás felhasználónév/jelszó";
              } else {
                return parsedJson["error_description"];
              }
            } else {
              globals.token = parsedJson["access_token"];
              return "OK";
            }
            //print(status);
          } else if (response.statusCode == 401) {
            var parsedJson = json.decode(response.body);
            if (parsedJson["error_description"] == '' ||
                parsedJson["error_description"] == null) {
              return "Hibás felhasználónév/jelszó";
            } else {
              return parsedJson["error_description"];
            }
            //print('Response status: ${response.statusCode}');
          } else {
            return 'post error: statusCode= ${response.statusCode}';
          }
        } on SocketException {
          return "Rossz iskola azonosító";
        }
      }
    } catch (e, s) {
      var client = http.Client();
      var header = {
        'User-Agent': '$agent',
        'Content-Type': 'application/json',
      };
      var res;
      try {
        res = await client.get('https://api.novy.vip/kretaHeader.json',
            headers: header);
        if (res.statusCode == 200) {
          agent = json.decode(res.body)["header"];
          config.currAgent = agent = json.decode(res.body)["header"];
          if (tokenIndex < 3) {
            getToken(code, user, pass);
          } else {
            Crashlytics.instance.recordError(e, s, context: 'getToken');
            return "Nincs válasz a krétától!\nPróbáld újra később!";
          }
        }
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'getToken');
        return "Nincs válasz a novy API-tól!\nPróbáld újra később!";
      }
    }
    return "Error";
  }

  Future<void> getStudentInfo(token, code) async {
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
      var eval = globals.dJson["Evaluations"];
      await getAvarages(token, code);
      globals.markCount = eval.length;
      marksPage.colors = getRandomColors(globals.markCount);
      marksPage.allParsedByDate = await parseAllByDate(globals.dJson);
      marksPage.allParsedBySubject = parseAllBySubject(globals.dJson);
      globals.noticesCount = countNotices(globals.dJson);
      noticesPage.allParsedNotices = await parseNotices(globals.dJson);
      statisticsPage.allParsedSubjects = categorizeSubjects(globals.dJson);
      statisticsPage.colors =
          getRandomColors(statisticsPage.allParsedSubjects.length);
      timetablePage.lessonsList = await getWeekLessons(token, code);
      setUpCalculatorPage(statisticsPage.allParsedSubjects);
    }
  }

  Future<void> getAvarages(var token, code) async {
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
      globals.avJson = bodyJson;
      avaragesPage.avarageList = await parseAvarages(globals.avJson);
    }
  }

  Future<dynamic> getSchoolList() async {
    List<School> tempList = [];
    School tempSchool = new School();
    var client = http.Client();
    var header = {
      'User-Agent': '$agent',
      'Content-Type': 'application/json',
    };
    var res;
    try {
      res = await client
          .get('https://api.novy.vip/schoolList.json', headers: header)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      print("TIMEOUT");
      return "TIMEOUT";
    } finally {
      client.close();
    }
    await sleep1();
    if (res.statusCode != 200) {
      print(res.statusCode);
      return res.statusCode;
    }
    List<dynamic> responseJson = json.decode(utf8.decode(res.bodyBytes));
    for (var n in responseJson) {
      tempSchool = new School();
      tempSchool.id = n["InstituteId"];
      tempSchool.name = n["Name"];
      tempSchool.code = n["InstituteCode"];
      tempSchool.url = n["Url"];
      tempSchool.city = n["City"];
      tempList.add(tempSchool);
    }
    return tempList;
  }

  Future<List<List<Lesson>>> getWeekLessons(token, code) async {
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
      tempLessonList.add(await setLesson(n, token, code));
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
        await batchInsertLessons(tempLessonListForDB);
      }
    }
    return output;
  }
}

void setUpCalculatorPage(List<List<Evals>> input) {
  calculatorPage.dropdownValues = [];
  calculatorPage.dropdownValue = "";
  calculatorPage.avarageList = [];
  if (input != null && input != [[]] && input.length != 1) {
    double sum, index;
    for (var n in input) {
      calculatorPage.dropdownValues.add(capitalize(n[0].subject));
      sum = 0;
      index = 0;
      for (var y in n) {
        sum += y.numberValue * double.parse(y.weight.split("%")[0]) / 100;
        index += 1 * double.parse(y.weight.split("%")[0]) / 100;
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
    calculatorPage.dropdownValue = "Az lehet, hogy még nincs jegyed?";
}

Future<Homework> setTeacherHomework(int hwId, String token, String code) async {
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
  //*Add it to the database
  //TODO batchify
  await insertHomework(temp);
  //Find the same ids
  var matchedIds = homeworkPage.globalHomework.where((element) {
    return element.id == temp.id;
  });
  if (matchedIds.length == 0) {
    homeworkPage.globalHomework.add(temp);
  } else {
    var matchedindex = homeworkPage.globalHomework.indexWhere((element) {
      return element.id == temp.id;
    });
    homeworkPage.globalHomework[matchedindex] = temp;
  }
  homeworkPage.globalHomework.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return temp;
}
