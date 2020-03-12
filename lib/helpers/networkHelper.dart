import 'package:connectivity/connectivity.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/screens/login_page.dart' as loginPage;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/charts_tab.dart' as chartsPage;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:novynaplo/config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:novynaplo/functions/utils.dart';

String agent = config.currAgent;
var response;

class NetworkHelper {
  Future<ConnectivityResult> isNetworkAvailable() async {
    return await (Connectivity().checkConnectivity());
  }

  Future<String> getToken(code, user, pass) async {
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
        response = await http.post('https://$code.e-kreta.hu/idp/api/v1/Token',
            headers: headers, body: data);
        //print(response.body);
        /*var url = 'https://novy.vip/api/login.php?code=$code&user=$user&pass=$pass';
    var response = await http.get(url);*/
        //print(response.body);
        if (response.statusCode == 200) {
          var parsedJson = json.decode(response.body);
          //print('Response body: ${response.body}');
          var status = parsedJson['token_type'];
          if (status == '' || status == null) {
            if (parsedJson["error_description"] == '' ||
                parsedJson["error_description"] == null) {
              return "Hibás felhasználónév/jelszó";
            } else {
              return parsedJson["error_description"];
            }
          } else {
            loginPage.token = parsedJson["access_token"];
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
          throw Exception('post error: statusCode= ${response.statusCode}');
        }
      } on SocketException {
        return "Rossz iskola azonosító";
      }
    }
  }

  Future<void> getStudentInfo(token, code) async {
    var headers = {
      'Authorization': 'Bearer $token',
      'User-Agent': '$agent',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/Student?fromDate=null&toDate=null',
        headers: headers);
    if (res.statusCode != 200)
      throw Exception('get error: statusCode= ${res.statusCode}');
    if (res.statusCode == 200) {
      loginPage.dJson = json.decode(res.body);
      var eval = loginPage.dJson["Evaluations"];
      if (loginPage.markCount != 0) loginPage.markCount = 0;
      if (loginPage.avarageCount != 0) loginPage.avarageCount = 0;
      if (loginPage.noticesCount != 0) loginPage.noticesCount = 0;
      eval.forEach((element) => loginPage.markCount += 1);
      loginPage.avarageCount = countAvarages(loginPage.dJson);
      loginPage.noticesCount = countNotices(loginPage.dJson);
      noticesPage.allParsedNotices = parseNotices(loginPage.dJson);
      chartsPage.allParsedSubjects = categorizeSubjects(loginPage.dJson);
      chartsPage.colors = getRandomColors(chartsPage.allParsedSubjects.length);
      timetablePage.lessonsList = await getWeekLessons(token, code);
      setUpCalculatorPage(loginPage.dJson);
    }
  }

  Future<dynamic> getSchoolList() async {
    List<School> tempList = [];
    School tempSchool = new School();
    var client = http.Client();
    var header = {
      'User-Agent': '$agent',
      'Content-Type': 'application/json',
      'apiKey': '7856d350-1fda-45f5-822d-e1a2f3f1acf0',
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
        'https://$code.e-kreta.hu/mapi/api/v1/Lesson?fromDate=$startDate&toDate=$endDate',
        headers: header);
    if (res.statusCode != 200) {
      print(res.statusCode);
    }
    //Process response
    var decoded = json.decode(res.body);
    List<Lesson> tempLessonList = [];
    for (var n in decoded) {
      tempLessonList.add(setLesson(n));
    }
    tempLessonList.sort((a, b) => a.startDate.compareTo(b.startDate));
    int index = 0;
    int beforeDay = tempLessonList[0].startDate.day;
    //Just a matrix
    for (var n in tempLessonList) {
      if (n.startDate.day != beforeDay) {
        index++;
        beforeDay = n.startDate.day;
      }
      output[index].add(n);
    }
    return output;
  }
}

void setUpCalculatorPage(var dJson) {
  calculatorPage.avarageList = [];
  calculatorPage.dropdownValues = [];
  for (var n in dJson["SubjectAverages"]) {
    calculatorPage.avarageList.add(setCalcData(n["Value"], n["Subject"], 0, 0));
    calculatorPage.dropdownValues.add(capitalize(n["Subject"]));
  }
  for (var n in dJson["Evaluations"]) {
    int indexA =
        calculatorPage.avarageList.indexWhere((a) => a.name == n["Subject"]);
    if (indexA >= 0 && n["Type"] != "HalfYear" && n["Form"] != "Percent") {
      calculatorPage.avarageList[indexA].count++;
      calculatorPage.avarageList[indexA].sum += n["NumberValue"];
    }
  }
  calculatorPage.dropdownValue = calculatorPage.dropdownValues[0];
}
