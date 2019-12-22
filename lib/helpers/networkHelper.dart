import 'dart:ffi';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:novynaplo/screens/charts_tab.dart';
import 'package:novynaplo/screens/login_page.dart' as loginPage;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/charts_tab.dart' as chartsPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:novynaplo/config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/functions/utils.dart';

var agent = config.currAgent;
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
      //print(dJson);
    }
  }
}
