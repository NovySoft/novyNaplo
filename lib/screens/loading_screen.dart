import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

var passKey = encrypt.Key.fromUtf8(config.passKey);
var codeKey = encrypt.Key.fromUtf8(config.codeKey);
var userKey = encrypt.Key.fromUtf8(config.userKey);
final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
String decryptedCode,
    decryptedUser,
    decryptedPass,
    loadingText = "Kérlek várj...";
var status;
String agent = config.currAgent;
var response;
bool hasError = false;
int tokenIndex = 0;

class LoadingPage extends StatefulWidget {
  static String tag = 'loading-page';
  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  //Network start
  void setUpCalculatorPage(List<List<Evals>> input) {
    setState(() {
      loadingText = "Jegyszámoló beállítása";
    });
    calculatorPage.dropdownValues = [];
    calculatorPage.dropdownValue = "";
    calculatorPage.avarageList = [];
    if (input != null && input != [[]]) {
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

  Future<ConnectivityResult> isNetworkAvailable() async {
    setState(() {
      loadingText = "Hálózat ellenőrzése";
    });
    return await (Connectivity().checkConnectivity());
  }

  void getToken(code, user, pass) async {
    tokenIndex++;
    try {
      if (code == "" || user == "" || pass == "") {
        afterTokenGrab(context, "Hiányzó bemenet");
      } else {
        setState(() {
          loadingText = "Token lekérése";
        });
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
            setState(() {
              loadingText = "Token dekódolása";
            });
            var parsedJson = json.decode(response.body);
            var status = parsedJson['token_type'];
            if (status == '' || status == null) {
              if (parsedJson["error_description"] == '' ||
                  parsedJson["error_description"] == null) {
                afterTokenGrab(context, "Hibás felhasználónév/jelszó");
              } else {
                afterTokenGrab(context, parsedJson["error_description"]);
              }
            } else {
              globals.token = parsedJson["access_token"];
              afterTokenGrab(context, "OK");
            }
            //print(status);
          } else if (response.statusCode == 401) {
            var parsedJson = json.decode(response.body);
            if (parsedJson["error_description"] == '' ||
                parsedJson["error_description"] == null) {
              afterTokenGrab(context, "Hibás felhasználónév/jelszó");
            } else {
              afterTokenGrab(context, parsedJson["error_description"]);
            }
            //print('Response status: ${response.statusCode}');
          } else {
            _ackAlert(
                context, 'post error: statusCode= ${response.statusCode}');
          }
        } on SocketException {
          afterTokenGrab(context, "Rossz iskola azonosító");
        }
      }
    } catch (e, s) {
      setState(() {
        loadingText = "Hiba a tokennel való lekérés közben\nÚjra próbálkozás";
      });
      var client = http.Client();
      var header = {
        'User-Agent': '$agent',
        'Content-Type': 'application/json',
      };
      var res;
      try {
        setState(() {
          loadingText = "Újra kezdés!";
        });
        res = await client.get('https://api.novy.vip/kretaHeader.json',
            headers: header);
        if (res.statusCode == 200) {
          agent = json.decode(res.body)["header"];
          config.currAgent = agent = json.decode(res.body)["header"];
          if (tokenIndex < 3) {
            getToken(code, user, pass);
          } else {
            Crashlytics.instance.recordError(e, s, context: 'getToken');
            _ackAlert(
                context, "Nincs válasz a krétától!\nPróbáld újra később!");
          }
        }
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'getToken');
        _ackAlert(
            context, "Nincs válasz a novy API-tól!\nPróbáld újra később!");
      }
    }
  }

  Future<void> getStudentInfo(token, code) async {
    try {
      setState(() {
        loadingText = "Jegyek lekérése";
      });
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
        setState(() {
          loadingText = "Jegyek dekódolása";
        });
        globals.dJson = json.decode(res.body);
        var eval = globals.dJson["Evaluations"];
        if (globals.markCount != 0) globals.markCount = 0;
        if (globals.avarageCount != 0) globals.avarageCount = 0;
        if (globals.noticesCount != 0) globals.noticesCount = 0;
        await getAvarages(token, code);
        if (eval != null)
          globals.markCount = eval.length;
        else
          globals.markCount = 0;
        globals.noticesCount = countNotices(globals.dJson);
        noticesPage.allParsedNotices = parseNotices(globals.dJson);
        statisticsPage.allParsedSubjects = categorizeSubjects(globals.dJson);
        statisticsPage.colors =
            getRandomColors(statisticsPage.allParsedSubjects.length);
        timetablePage.lessonsList = await getWeekLessons(token, code);
        setUpCalculatorPage(statisticsPage.allParsedSubjects);
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: loadingText);
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újraindítása.\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel!");
    }
  }

  Future<void> getAvarages(var token, code) async {
    try {
      setState(() {
        loadingText = "Átlagok lekérése";
      });
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
        setState(() {
          loadingText = "Átlagok dekódolása";
        });
        var bodyJson = json.decode(res.body);
        globals.avJson = bodyJson;
        globals.avarageCount = countAvarages(bodyJson);
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getAvarages');
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újraindítása.\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel!");
    }
  }

  Future<List<List<Lesson>>> getWeekLessons(token, code) async {
    try {
      setState(() {
        loadingText = "Órarend előkészítése";
      });
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
      setState(() {
        loadingText = "Órarend lekérése";
      });

      var res = await http.get(
          'https://$code.e-kreta.hu/mapi/api/v1/LessonAmi?fromDate=$startDate&toDate=$endDate',
          headers: header);
      if (res.statusCode != 200) {
        print(res.statusCode);
      }
      //Process response
      var decoded = json.decode(res.body);
      setState(() {
        loadingText = "Órarend dekódolása\nHázifeladatok lekérése";
      });
      List<Lesson> tempLessonList = [];
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
          }
        }
      }
      return output;
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getWeekLessons');
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újraindítása.\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel!");
    }
  }
  //NETWORK END

  void onLoad(var context) async {
    Crashlytics.instance.setString("Version", config.currentAppVersionCode);
    NewVersion newVerDetails = await getVersion();
    if (newVerDetails.returnedAnything) {
      if (config.currentAppVersionCode != newVerDetails.versionCode) {
        setState(() {
          loadingText = "Verzió ellenőrzése";
        });
        await _newVersionAlert(
            context,
            newVerDetails.versionCode,
            newVerDetails.releaseNotes,
            newVerDetails.isBreaking,
            newVerDetails.releaseLink);
      }
    }
    setState(() {
      loadingText = "Addatok olvasása a memóriából";
    });
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
      decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
      decryptedUser = userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
      decryptedPass =
          userEncrypter.decrypt64(prefs.getString("password"), iv: iv);
      globals.setGlobals();
      if (prefs.getBool("ads") != null) {
        Crashlytics.instance.setBool("Ads", prefs.getBool("ads"));
        if (prefs.getBool("ads")) {
          adBanner.load();
          adBanner.show(
            anchorType: AnchorType.bottom,
          );
          globals.adsEnabled = true;
          globals.adModifier = 1;
        } else {
          globals.adModifier = 0;
          globals.adsEnabled = false;
        }
      } else {
        globals.adsEnabled = false;
      }
      //print("ads" + globals.adsEnabled.toString());
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'onLoad-prefs');
      globals.resetAllGlobals();
      await _ackAlert(context,
          "Hiba a memóriából való olvasás közben ($e)\nAjánlott az alkalmazás újraindítása\nMemória törölve...");
    }
    auth(context);
  }

  void afterTokenGrab(var context, String status) async {
    if (status == "OK") {
      await getStudentInfo(globals.token, decryptedCode);
      if (status == "OK") {
        try {
          save(context);
        } catch (e, s) {
          Crashlytics.instance.recordError(e, s, context: 'afterTokenGrab');
          await _ackAlert(context,
              "Hiba: $e\nAjánlott az alkalmazás újraindítása.\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel!");
        }
      } else {
        if (status != null) {
          await _ackAlert(
              context,
              "HTTP hiba: " +
                  status.toString() +
                  "\nAjánlott az alkalmazás újraindítása.\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel!");
        } else {
          await _ackAlert(context,
              "Ismeretlen HTTP hiba\nAjánlott az alkalmazás újraindítása.\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel!");
          return;
        }
      }
    }
  }

  void auth(var context) async {
    try {
      if (await isNetworkAvailable() == ConnectivityResult.none) {
        afterTokenGrab(context, "No internet connection was detected");
      } else {
        getToken(decryptedCode, decryptedUser, decryptedPass);
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'auth');
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újraindítása.\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel!");
    }
  }

  void save(var context) async {
    setState(() {
      loadingText = "Mindjárt megvagyunk!";
    });
    FirebaseAnalytics().setUserProperty(name: "School", value: decryptedCode);
    Crashlytics.instance.setString("School", decryptedCode);
    FirebaseAnalytics()
        .setUserProperty(name: "Version", value: config.currentAppVersionCode);
    Crashlytics.instance.setString("Version", config.currentAppVersionCode);
    if (hasError) {
      setState(() {
        loadingText = "Hiba történt\nKérem indítsa újra az applikációt!";
      });
    } else {
      Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: config.adMob);
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad(context));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 75.0,
          child: Image.asset('assets/home.png')),
    );
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 5.0),
            Center(
              child: Text(
                "Üdv a Novy Naplóban!",
                style: TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SpinKitPouringHourglass(color: Colors.lightBlueAccent),
            SizedBox(height: 10),
            Text(
              loadingText,
              style: TextStyle(color: Colors.blueAccent, fontSize: 20),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _newVersionAlert(BuildContext context, String version,
      String notes, bool isBreaking, String link) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Új verzió: $version"),
          content: SingleChildScrollView(
            child:
                Column(children: <Widget>[Text("Megjegyzések:"), Text(notes)]),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Frissítés'),
              onPressed: () async {
                if (await canLaunch(link)) {
                  await launch(link);
                } else {
                  FirebaseAnalytics().logEvent(name: "LinkFail");
                  throw 'Could not launch $link';
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _ackAlert(BuildContext context, String content) async {
    hasError = true;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Státusz'),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
