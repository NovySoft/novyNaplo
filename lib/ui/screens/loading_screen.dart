import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:novynaplo/data/database/absences.dart';
import 'package:novynaplo/data/database/evals.dart';
import 'package:novynaplo/data/database/events.dart';
import 'package:novynaplo/data/database/homework.dart';
import 'package:novynaplo/data/database/notices.dart';
import 'package:novynaplo/data/database/users.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/logicAndMath/getMarksWithChanges.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/logicAndMath/setUpMarkCalculator.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/login_page.dart' as loginPage;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/helpers/ui/adHelper.dart';
import 'package:novynaplo/helpers/notificationHelper.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'package:novynaplo/data/database/getSql.dart';
import 'package:novynaplo/data/models/extensions.dart';

String loadingText = "${getTranslatedString("plsWait")}...";
var status;
String agent = config.userAgent;
var response;
bool hasError = false;
int tokenIndex = 0;

class LoadingPage extends StatefulWidget {
  static String tag = 'loading-page';
  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  //Runs after initState
  void onLoad(var context) async {
    FirebaseCrashlytics.instance.log("Shown Loading screen");
    try {
      await globals.setGlobals();
      List<Student> allUsers = await getAllUsers();
      if (allUsers.length <= 0) {
        Navigator.pushReplacementNamed(context, loginPage.LoginPage.tag);
        return;
      }
      globals.currentUser = allUsers.firstWhere(
        (element) => element.current,
        orElse: () => allUsers[0],
      );
      //FIXME status szöveg hozzáadása
      setState(() {
        loadingText = getTranslatedString("checkVersion");
      });
      FirebaseCrashlytics.instance
          .setCustomKey("Version", config.currentAppVersionCode);
      if (globals.verCheckOnStart) {
        await getVersion();
      }
      if (globals.prefs.getString("FirstOpenTime") != null) {
        if (DateTime.parse(globals.prefs.getString("FirstOpenTime"))
                    .difference(DateTime.now()) >=
                Duration(days: 14) &&
            globals.prefs.getBool("ShouldAsk") &&
            DateTime.parse(globals.prefs.getString("LastAsked"))
                    .difference(DateTime.now()) >=
                Duration(days: 2) &&
            config.isAppPlaystoreRelease) {
          setState(() {
            loadingText = getTranslatedString("reviewProcess");
          });
          await showReviewWindow(context);
        }
      }
      //Load ADS
      if (globals.prefs.getBool("ads") != null) {
        FirebaseCrashlytics.instance
            .setCustomKey("Ads", globals.prefs.getBool("ads"));
        if (globals.prefs.getBool("ads")) {
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
      //*Marks
      setState(() {
        loadingText = getTranslatedString("readMarks");
      });
      List<Evals> tempEvals = await getAllEvals();
      marksPage.colors = getRandomColors(tempEvals.length);
      marksPage.allParsedByDate = tempEvals;
      marksPage.allParsedBySubject = sortByDateAndSubject(tempEvals);
      //*Load variables required to use the markCalculator
      setState(() {
        loadingText = getTranslatedString("setUpMarkCalc");
      });
      setUpCalculatorPage(statisticsPage.allParsedSubjects);
      //*Load variables required to show statistics
      setState(() {
        loadingText = getTranslatedString("setUpStatistics");
      });
      statisticsPage.allParsedSubjects =
          categorizeSubjectsFromEvals(marksPage.allParsedByDate);
      statisticsPage.allParsedSubjectsWithoutZeros = List.from(
        statisticsPage.allParsedSubjects
            .where((element) => element[0].numberValue != 0),
      );
      //*Notices
      setState(() {
        loadingText = getTranslatedString("readNotices");
      });
      noticesPage.allParsedNotices = await getAllNotices();
      //*Events
      setState(() {
        loadingText = getTranslatedString("readEvents");
      });
      eventsPage.allParsedEvents = await getAllEvents();
      //*Absences
      setState(() {
        loadingText = getTranslatedString("readAbsences");
      });
      absencesPage.allParsedAbsences = await getAllAbsencesMatrix();
      //*Homework
      setState(() {
        loadingText = getTranslatedString("readHw");
      });
      homeworkPage.globalHomework = await getAllHomework(ignoreDue: false);
      //*Done
      FirebaseAnalytics().logEvent(name: "login");
      Navigator.pushReplacementNamed(context, marksPage.MarksTab.tag);
      return;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'onLoad');
      await _ackAlert(
        context,
        "${getTranslatedString("errReadMem")} ($e, $s) ${getTranslatedString("restartApp")}",
      );
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
    final logo = CircleAvatar(
      backgroundColor: Colors.grey,
      radius: 75.0,
      child: Image.asset('assets/home.png'),
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

  Future<void> showReviewWindow(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            globals.prefs.setString("LastAsked", DateTime.now().toString());
            globals.prefs.setBool("ShouldAsk", true);
            FirebaseAnalytics().logEvent(
              name: "seenReviewPopUp",
              parameters: {"Action": "Later"},
            );
            return true;
          },
          child: AlertDialog(
            title: Text(getTranslatedString("review")),
            content: Text(getTranslatedString("plsRateUs")),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  getTranslatedString("yes"),
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  final InAppReview inAppReview = InAppReview.instance;

                  if (await inAppReview.isAvailable()) {
                    inAppReview.requestReview();
                  } else {
                    inAppReview.openStoreListing();
                  }
                  globals.prefs.setBool("ShouldAsk", false);
                  FirebaseAnalytics().logEvent(
                    name: "ratedApp",
                  );
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  getTranslatedString("later"),
                  style: TextStyle(color: Colors.orange),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  globals.prefs
                      .setString("LastAsked", DateTime.now().toString());
                  globals.prefs.setBool("ShouldAsk", true);
                  FirebaseAnalytics().logEvent(
                    name: "seenReviewPopUp",
                    parameters: {"Action": "Later"},
                  );
                },
              ),
              FlatButton(
                child: Text(
                  getTranslatedString("never"),
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  globals.prefs.setBool("ShouldAsk", false);
                  Navigator.of(context).pop();
                  FirebaseAnalytics().logEvent(
                    name: "seenReviewPopUp",
                    parameters: {"Action": "Never"},
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
