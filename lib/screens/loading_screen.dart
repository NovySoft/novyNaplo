import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/helpers/notificationHelper.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/screens/avarages_tab.dart' as avaragesPage;
import 'package:novynaplo/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:novynaplo/database/getSql.dart';

var passKey = encrypt.Key.fromUtf8(config.passKey);
var codeKey = encrypt.Key.fromUtf8(config.codeKey);
var userKey = encrypt.Key.fromUtf8(config.userKey);
final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
String decryptedCode,
    decryptedUser,
    decryptedPass,
    loadingText = "${getTranslatedString("plsWait")}...";
var status;
String agent = config.currAgent;
var response;
bool hasError = false;
int tokenIndex = 0;

//TODO: Rewrite to use only networkHelper
class LoadingPage extends StatefulWidget {
  static String tag = 'loading-page';
  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  //Network start
  void setUpCalculatorPage(List<List<Evals>> input) {
    setState(() {
      loadingText = getTranslatedString("setUpMarkCalc");
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
      calculatorPage.dropdownValue = getTranslatedString("possibleNoMarks");
  }

  Future<ConnectivityResult> isNetworkAvailable() async {
    setState(() {
      loadingText = getTranslatedString("checkNet");
    });
    return await (Connectivity().checkConnectivity());
  }

  void getToken(code, user, pass) async {
    tokenIndex++;
    try {
      if (code == "" || user == "" || pass == "") {
        afterTokenGrab(context, getTranslatedString("missingInput"));
      } else {
        setState(() {
          loadingText = getTranslatedString("getToken");
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
              loadingText = getTranslatedString("decodeToken");
            });
            var parsedJson = json.decode(response.body);
            var status = parsedJson['token_type'];
            if (status == '' || status == null) {
              if (parsedJson["error_description"] == '' ||
                  parsedJson["error_description"] == null) {
                afterTokenGrab(context, getTranslatedString("wrongUserPass"));
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
              afterTokenGrab(context, getTranslatedString("wrongUserPass"));
            } else {
              afterTokenGrab(context, parsedJson["error_description"]);
            }
            //print('Response status: ${response.statusCode}');
          } else {
            _ackAlert(
              context,
              'post error: statusCode= ${response.statusCode}',
            );
          }
        } on SocketException {
          afterTokenGrab(context, getTranslatedString("wrongSchId"));
        }
      }
    } catch (e, s) {
      setState(() {
        loadingText = getTranslatedString("errToken");
      });
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
            _ackAlert(
              context,
              getTranslatedString("noAns"),
            );
          }
        }
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'getToken');
        _ackAlert(
          context,
          getTranslatedString("noAnsNovy"),
        );
      }
    }
  }

  Future<void> getEvents(token, code) async {
    try {
      setState(() {
        loadingText = getTranslatedString("getEvents");
      });
      var headers = {
        'Authorization': 'Bearer $token',
        'User-Agent': '$agent',
      };

      var res = await http.get('https://$code.e-kreta.hu/mapi/api/v1/EventAmi',
          headers: headers);
      if (res.statusCode != 200)
        throw Exception('get error: statusCode= ${res.statusCode}');
      if (res.statusCode == 200) {
        setState(() {
          loadingText = getTranslatedString("decodeEvents");
        });
        var bodyJson = json.decode(res.body);
        eventsPage.allParsedEvents = await parseEvents(bodyJson);
        eventsPage.allParsedEvents.sort((a, b) => b.date.compareTo(a.date));
        setState(() {
          loadingText = getTranslatedString("saveEvents");
        });
        if (globals.offlineModeDb || globals.backgroundFetch) {
          await batchInsertEvents(eventsPage.allParsedEvents);
        }
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getEvents');
      await _ackAlert(
        context,
        "${getTranslatedString("err")}: $e ${getTranslatedString("generalErrDesc")}",
      );
    }
  }

  Future<void> getExams(token, code) async {
    try {
      setState(() {
        loadingText = getTranslatedString("getUpExams");
      });
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
        setState(() {
          loadingText = getTranslatedString("decodeExams");
        });
        //print("res.body ${res.body}");
        var bodyJson = json.decode(res.body);
        examsPage.allParsedExams = await parseExams(bodyJson);
        examsPage.allParsedExams
            .sort((a, b) => b.dateWrite.compareTo(a.dateWrite));
        setState(() {
          loadingText = getTranslatedString("saveExam");
        });
        if (globals.offlineModeDb || globals.backgroundFetch) {
          await batchInsertExams(examsPage.allParsedExams);
        }
        //print("examsPage.allParsedExams ${examsPage.allParsedExams}");
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getExams');
      await _ackAlert(
        context,
        "${getTranslatedString("err")}: $e ${getTranslatedString("generalErrDesc")}",
      );
    }
  }

  Future<void> getStudentInfo(token, code) async {
    try {
      setState(() {
        loadingText = getTranslatedString("getMarks");
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
          loadingText = getTranslatedString("decodeMarks");
        });
        globals.dJson = json.decode(res.body);
        if (!config.isAppPlaystoreRelease) {
          Crashlytics.instance.setUserName(globals.dJson["Name"]);
          Crashlytics.instance.setString("User", globals.dJson["Name"]);
        }
        var eval = globals.dJson["Evaluations"];
        await getAvarages(token, code);
        await getExams(token, code);
        await getEvents(token, code);
        globals.markCount = eval.length;
        marksPage.colors = getRandomColors(globals.markCount);
        marksPage.allParsedByDate = await parseAllByDate(globals.dJson);
        marksPage.allParsedBySubject =
            sortByDateAndSubject(List.from(marksPage.allParsedByDate));
        globals.noticesCount = countNotices(globals.dJson);
        noticesPage.allParsedNotices = await parseNotices(globals.dJson);
        statisticsPage.allParsedSubjects = categorizeSubjects(globals.dJson);
        statisticsPage.colors =
            getRandomColors(statisticsPage.allParsedSubjects.length);
        timetablePage.lessonsList = await getWeekLessons(token, code);
        setUpCalculatorPage(statisticsPage.allParsedSubjects);
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: loadingText);
      await _ackAlert(
        context,
        "${getTranslatedString("err")}: $e ${getTranslatedString("generalErrDesc")}",
      );
    }
  }

  Future<void> getAvarages(var token, code) async {
    try {
      setState(() {
        loadingText = getTranslatedString("getAvs");
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
          loadingText = getTranslatedString("decodeAvs");
        });
        var bodyJson = json.decode(res.body);
        globals.avJson = bodyJson;
        avaragesPage.avarageList = await parseAvarages(globals.avJson);
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getAvarages');
      await _ackAlert(
        context,
        "${getTranslatedString("err")}: $e ${getTranslatedString("generalErrDesc")}",
      );
    }
  }

  Future<List<List<Lesson>>> getWeekLessons(token, code) async {
    try {
      setState(() {
        loadingText = getTranslatedString("getTimetableReady");
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
        loadingText = getTranslatedString("getTimetable");
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
        loadingText = getTranslatedString("decTimetable");
      });
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
          setState(() {
            loadingText = getTranslatedString("savTimetable");
          });
          if (globals.offlineModeDb || globals.backgroundFetch) {
            await batchInsertLessons(tempLessonListForDB);
          }
        }
      }
      return output;
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getWeekLessons');
      await _ackAlert(
        context,
        "${getTranslatedString("err")}: $e ${getTranslatedString("generalErrDesc")}",
      );
    }
    return [];
  }
  //NETWORK END

  //Runs after initState
  void onLoad(var context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await globals.setGlobals();
      setState(() {
        loadingText = getTranslatedString("checkVersion");
      });
      Crashlytics.instance.setString("Version", config.currentAppVersionCode);
      if (prefs.getBool("getVersion")) {
        await getVersion();
      }
      //Load ADS
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
      //If we have prefetched data
      if (globals.backgroundFetch || globals.offlineModeDb) {
        //MARKS
        setState(() {
          loadingText = getTranslatedString("readMarks");
        });
        List<Evals> tempEvals = await getAllEvals();
        globals.markCount = tempEvals.length;
        marksPage.colors = getRandomColors(globals.markCount);
        marksPage.allParsedByDate = tempEvals;
        marksPage.allParsedBySubject = sortByDateAndSubject(tempEvals);
        //Homework
        setState(() {
          loadingText = getTranslatedString("readHw");
        });
        homeworkPage.globalHomework = await getAllHomework(ignoreDue: false);
        homeworkPage.globalHomework
            .sort((a, b) => a.dueDate.compareTo(b.dueDate));
        //Notices
        setState(() {
          loadingText = getTranslatedString("readNotices");
        });
        noticesPage.allParsedNotices = await getAllNotices();
        //Avarages
        setState(() {
          loadingText = getTranslatedString("readAvs");
        });
        avaragesPage.avarageList = await getAllAvarages();
        //Statisztika
        statisticsPage.allParsedSubjects =
            categorizeSubjectsFromEvals(marksPage.allParsedByDate);
        statisticsPage.colors =
            getRandomColors(statisticsPage.allParsedSubjects.length);
        setUpCalculatorPage(statisticsPage.allParsedSubjects);
        //Timetable
        setState(() {
          loadingText = getTranslatedString("readTimetable");
        });
        timetablePage.lessonsList =
            await getWeekLessonsFromLessons(await getAllTimetable());
        //Sort
        marksPage.allParsedByDate
            .sort((a, b) => b.createDateString.compareTo(a.createDateString));
        //Exams
        setState(() {
          loadingText = getTranslatedString("readExam");
        });
        examsPage.allParsedExams = await getAllExams();
        examsPage.allParsedExams
            .sort((a, b) => b.dateWrite.compareTo(a.dateWrite));
        //Events
        setState(() {
          loadingText = getTranslatedString("readEvents");
        });
        eventsPage.allParsedEvents = await getAllEvents();
        eventsPage.allParsedEvents.sort((a, b) => b.date.compareTo(a.date));
        //DONE
        setState(() {
          loadingText = "${getTranslatedString("almReady")}!";
        });
        //In case there's an error, we get the data instead of showing no data (although no data maybe correct)
        if ((tempEvals.length != 0 &&
                homeworkPage.globalHomework.length != 0 &&
                noticesPage.allParsedNotices.length != 0 &&
                avaragesPage.avarageList.length != 0 &&
                timetablePage.lessonsList.length != 0) ||
            await Connectivity().checkConnectivity() ==
                ConnectivityResult.none) {
          if (globals.notificationAppLaunchDetails.didNotificationLaunchApp) {
            //print("NotifLaunchApp");
            if (globals.notificationAppLaunchDetails.payload == "teszt") {
              //print("TESZT");
              Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
              showTesztNotificationDialog();
            } else {
              //print(globals.notificationAppLaunchDetails.payload);
              marksTab.redirectPayload = true;
              await sleep(10);
              Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
            }
          } else {
            Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
          }
          FirebaseAnalytics().logEvent(name: "login");
          return;
        }
      }
      print("NoData");
      //If we don't have prefetched data
      setState(() {
        loadingText = getTranslatedString("readData");
      });
      final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
      decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
      decryptedUser = userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
      decryptedPass =
          passEncrypter.decrypt64(prefs.getString("password"), iv: iv);
      //print("ads" + globals.adsEnabled.toString());
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'onLoad');
      await _ackAlert(
        context,
        "${getTranslatedString("errReadMem")} ($e, $s) ${getTranslatedString("restartApp")}",
      );
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
          await _ackAlert(
            context,
            "${getTranslatedString("err")}: $e ${getTranslatedString("generalErrDesc")}",
          );
        }
      } else {
        if (status != null) {
          await _ackAlert(
            context,
            "HTTP ${getTranslatedString("err")}: " +
                status.toString() +
                getTranslatedString("generalErrDesc"),
          );
        } else {
          await _ackAlert(
            context,
            "${getTranslatedString("unkown")} HTTP ${getTranslatedString("err")} ${getTranslatedString("generalErrDesc")}",
          );
          return;
        }
      }
    }
  }

  void auth(var context) async {
    try {
      if (await isNetworkAvailable() == ConnectivityResult.none) {
        afterTokenGrab(context, getTranslatedString("noNet"));
      } else {
        getToken(decryptedCode, decryptedUser, decryptedPass);
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'auth');
      await _ackAlert(
        context,
        "${getTranslatedString("err")}: $e ${getTranslatedString("generalErrDesc")}",
      );
    }
  }

  void save(var context) async {
    setState(() {
      loadingText = "${getTranslatedString("almReady")}!";
    });
    FirebaseAnalytics().setUserProperty(name: "School", value: decryptedCode);
    Crashlytics.instance.setString("School", decryptedCode);
    FirebaseAnalytics()
        .setUserProperty(name: "Version", value: config.currentAppVersionCode);
    Crashlytics.instance.setString("Version", config.currentAppVersionCode);
    if (hasError) {
      setState(() {
        loadingText = getTranslatedString("errRestart");
      });
    } else {
      Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
      FirebaseAnalytics().logEvent(name: "login");
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: config.adMob);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad(context);
    });
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
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 5.0),
            Center(
              child: Text(
                getTranslatedString("Welcome to novynaplo"),
                style: TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                "Ver: " + config.currentAppVersionCode,
                style: TextStyle(fontSize: 15),
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

  Future<void> _ackAlert(BuildContext context, String content) async {
    hasError = true;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslatedString("status")),
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
