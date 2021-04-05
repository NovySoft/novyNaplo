import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;
import 'data/database/databaseHelper.dart';
import 'data/models/student.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;

//Variables used globally;
//* Session
SharedPreferences prefs; //Global shared preferences
bool didFetch = false; //True if we fetched the data, false if we didn't
bool isNavigatorLoaded =
    false; //Stores whether the app has passed the loading stage, this variable is used to delay and show notifications
bool isDataLoaded =
    false; //Whether app data has been loaded, and we can start fetching data for notifications
Database db; //Global database access
Student currentUser = Student(); //The currently shown user
//* "Permanent"
String markCardSubtitle = "Téma"; //Marks subtitle
String markCardTheme = "Értékelés nagysága"; //Marks color theme
String markCardConstColor = "Orange"; //If theme is constant what color is it
String lessonCardSubtitle = "Tanterem"; //Lesson card's subtitle
String timetableCardTheme = "Subject"; //Timetable card's theme
String homeworkCardTheme = "Véletlenszerű"; //Homework card's theme
String noticesAndEventsCardTheme =
    "Véletlenszerű"; //Notices and exams card's theme
String examsCardTheme = "Subject"; //Exams card's theme
String statisticsCardTheme = "Véletlenszerű"; //Exams card's theme
bool timetableTextColSubject =
    false; //Timetable text color based on subject color?
bool marksTextColSubject = false; //Marks text color based on subject color?
bool examsTextColSubject = false; //Marks text color based on subject color?
String howManyGraph =
    "Kör diagram"; //What should we show? A pie- or a bar-chart
bool chartAnimations = true; //Do we need to animate the charts
bool shouldVirtualMarksCollapse = false; //Should we group virtual marks
bool backgroundFetch = true; //Should we fetch data in the background?
bool backgroundFetchCanWakeUpPhone =
    true; //Should we wake the phone up to fetch data?
bool backgroundFetchOnCellular = false; //Should we fetch on cellular data
int extraSpaceUnderStat = 0; //How many extra padding do we need?
int fetchPeriod = 30; //After how many minutes should we fetch the new data?
int splitChartLength = 17;
bool notifications = true; //Should we send notifications
double howLongKeepDataForHw = 7; //How long should we show homeworks (in days)
bool colorAvsInStatisctics =
    true; //Should we color the name of subjects based on their values
String language =
    "hu"; //Language to show stuff in, defualts to hungarian as you can see
bool collapseNotifications =
    true; //Automatically collapse all notifications, on by default
bool darker = false; //Darker theme

Future<void> resetAllGlobals() async {
  await DatabaseHelper.clearAllTables();
  await prefs.clear();
  await prefs.setBool("isNew", true);
  await prefs.setString("Language", language);
  didFetch = false;
  marksPage.allParsedByDate = [];
  marksPage.allParsedBySubject = [];
  statisticsPage.allParsedSubjects = [];
  statisticsPage.allParsedSubjectsWithoutZeros = [];
  noticesPage.allParsedNotices = [];
  eventsPage.allParsedEvents = [];
  absencesPage.allParsedAbsences = [];
  homeworkPage.globalHomework = [];
  examsPage.allParsedExams = [];
  timetablePage.lessonsList = [];
}

Future<void> setGlobals() async {
  prefs = await SharedPreferences.getInstance();
  if (prefs.getString("FirstOpenTime") == null) {
    await prefs.setString("FirstOpenTime", DateTime.now().toString());
    await prefs.setString("LastAsked", DateTime.now().toString());
  }

  if (prefs.getBool("ShouldAsk") == null) {
    await prefs.setBool("ShouldAsk", true);
  }

  if (prefs.getInt("splitChartLength") == null) {
    prefs.setInt("splitChartLength", splitChartLength);
  } else {
    splitChartLength = prefs.getInt("splitChartLength");
  }
  if (prefs.getString("Language") != null) {
    language = prefs.getString("Language");
  } else {
    //String countryCode = Platform.localeName.split('_')[0];
    if (Platform.localeName == null) {
      language = "en";
    } else {
      String languageCode = Platform.localeName.split('_')[1];
      if (languageCode.toLowerCase().contains('hu')) {
        language = "hu";
      } else {
        language = "en";
      }
    }
    prefs.setString("Language", language);
  }
  FirebaseAnalytics().setUserProperty(
    name: "Language",
    value: language,
  );
  FirebaseCrashlytics.instance.setCustomKey("Language", language);

  if (prefs.getBool("colorAvsInStatisctics") != null) {
    colorAvsInStatisctics = prefs.getBool("colorAvsInStatisctics");
  } else {
    await prefs.setBool("colorAvsInStatisctics", true);
    colorAvsInStatisctics = true;
  }

  if (prefs.getBool("darker") != null) {
    darker = prefs.getBool("darker");
  } else {
    await prefs.setBool("darker", false);
    darker = false;
  }

  if (prefs.getDouble("howLongKeepDataForHw") != null) {
    howLongKeepDataForHw = prefs.getDouble("howLongKeepDataForHw");
  } else {
    prefs.setDouble("howLongKeepDataForHw", 7);
    howLongKeepDataForHw = 7;
  }
  FirebaseCrashlytics.instance
      .setCustomKey("howLongKeepDataForHw", howLongKeepDataForHw);

  if (prefs.getBool("notifications") != null) {
    notifications = prefs.getBool("notifications");
  } else {
    await prefs.setBool("notifications", true);
    notifications = true;
  }
  FirebaseCrashlytics.instance.setCustomKey("notifications", notifications);
  FirebaseAnalytics().setUserProperty(
    name: "Notifications",
    value: notifications ? "ON" : "OFF",
  );

  if (prefs.getBool("backgroundFetchOnCellular") != null) {
    backgroundFetchOnCellular = prefs.getBool("backgroundFetchOnCellular");
  } else {
    await prefs.setBool("backgroundFetchOnCellular", false);
    backgroundFetchOnCellular = false;
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "backgroundFetchOnCellular",
    backgroundFetchOnCellular,
  );

  if (prefs.getInt("fetchPeriod") == null) {
    fetchPeriod = 30;
    prefs.setInt("fetchPeriod", 30);
  } else {
    fetchPeriod = prefs.getInt("fetchPeriod");
  }

  if (prefs.getBool("backgroundFetch") == null) {
    backgroundFetch = true;
    await prefs.setBool("backgroundFetch", true);
  } else {
    backgroundFetch = prefs.getBool("backgroundFetch");
  }
  FirebaseCrashlytics.instance.setCustomKey("backgroundFetch", backgroundFetch);

  if (prefs.getBool("backgroundFetchCanWakeUpPhone") == null) {
    backgroundFetchCanWakeUpPhone = true;
    await prefs.setBool("backgroundFetchCanWakeUpPhone", true);
  } else {
    backgroundFetchCanWakeUpPhone =
        prefs.getBool("backgroundFetchCanWakeUpPhone");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "backgroundFetchCanWakeUpPhone",
    backgroundFetchCanWakeUpPhone,
  );

  if (prefs.getBool("timetableTextColSubject") == null) {
    timetableTextColSubject = false;
    await prefs.setBool("timetableTextColSubject", timetableTextColSubject);
  } else {
    timetableTextColSubject = prefs.getBool("timetableTextColSubject");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "timetableTextColSubject",
    timetableTextColSubject,
  );

  if (prefs.getBool("marksTextColSubject") == null) {
    marksTextColSubject = false;
    await prefs.setBool("marksTextColSubject", marksTextColSubject);
  } else {
    marksTextColSubject = prefs.getBool("marksTextColSubject");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "marksTextColSubject",
    marksTextColSubject,
  );

  if (prefs.getBool("examsTextColSubject") == null) {
    examsTextColSubject = false;
    await prefs.setBool("examsTextColSubject", examsTextColSubject);
  } else {
    examsTextColSubject = prefs.getBool("examsTextColSubject");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "examsTextColSubject",
    examsTextColSubject,
  );

  if (prefs.getString("howManyGraph") == null) {
    howManyGraph = "Kör diagram";
    prefs.setString("howManyGraph", howManyGraph);
  } else {
    howManyGraph = prefs.getString("howManyGraph");
  }
  FirebaseCrashlytics.instance.setCustomKey("howManyGraph", howManyGraph);

  if (prefs.getInt("extraSpaceUnderStat") != null) {
    extraSpaceUnderStat = prefs.getInt("extraSpaceUnderStat");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("extraSpaceUnderStat", extraSpaceUnderStat);

  if (prefs.getBool("shouldVirtualMarksCollapse") == null) {
    shouldVirtualMarksCollapse = false;
    await prefs.setBool("shouldVirtualMarksCollapse", false);
  } else {
    shouldVirtualMarksCollapse = prefs.getBool("shouldVirtualMarksCollapse");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "shouldVirtualMarksCollapse",
    shouldVirtualMarksCollapse,
  );

  if (prefs.getString("markCardSubtitle") == null) {
    markCardSubtitle = "Téma";
    prefs.setString("markCardSubtitle", "Téma");
  } else {
    markCardSubtitle = prefs.getString("markCardSubtitle");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("markCardSubtitle", markCardSubtitle);

  if (prefs.getString("markCardConstColor") == null) {
    markCardConstColor = "Green";
    prefs.setString("markCardConstColor", "Green");
  } else {
    markCardConstColor = prefs.getString("markCardConstColor");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("markCardConstColor", markCardConstColor);

  if (prefs.getString("lessonCardSubtitle") == null) {
    lessonCardSubtitle = "Tanterem";
    prefs.setString("lessonCardSubtitle", "Tanterem");
  } else {
    lessonCardSubtitle = prefs.getString("lessonCardSubtitle");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("lessonCardSubtitle", lessonCardSubtitle);

  if (prefs.getString("markCardTheme") == null) {
    markCardTheme = "Értékelés nagysága";
    prefs.setString("markCardTheme", "Értékelés nagysága");
  } else {
    markCardTheme = prefs.getString("markCardTheme");
  }
  FirebaseCrashlytics.instance.setCustomKey("markCardTheme", markCardTheme);

  if (prefs.getString("timetableCardTheme") == null) {
    timetableCardTheme = "Subject";
    prefs.setString("timetableCardTheme", timetableCardTheme);
  } else {
    timetableCardTheme = prefs.getString("timetableCardTheme");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "timetableCardTheme",
    timetableCardTheme,
  );

  if (prefs.getString("homeworkCardTheme") == null) {
    homeworkCardTheme = "Véletlenszerű";
    prefs.setString("homeworkCardTheme", homeworkCardTheme);
  } else {
    homeworkCardTheme = prefs.getString("homeworkCardTheme");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "homeworkCardTheme",
    homeworkCardTheme,
  );

  if (prefs.getString("examsCardTheme") == null) {
    examsCardTheme = "Véletlenszerű";
    prefs.setString("examsCardTheme", examsCardTheme);
  } else {
    examsCardTheme = prefs.getString("examsCardTheme");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "examsCardTheme",
    examsCardTheme,
  );

  if (prefs.getString("statisticsCardTheme") == null) {
    statisticsCardTheme = "Véletlenszerű";
    prefs.setString("statisticsCardTheme", statisticsCardTheme);
  } else {
    statisticsCardTheme = prefs.getString("statisticsCardTheme");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "statisticsCardTheme",
    statisticsCardTheme,
  );

  if (prefs.getString("noticesAndEventsCardTheme") == null) {
    noticesAndEventsCardTheme = "Véletlenszerű";
    prefs.setString("noticesAndEventsCardTheme", noticesAndEventsCardTheme);
  } else {
    noticesAndEventsCardTheme = prefs.getString("noticesAndEventsCardTheme");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "noticesAndEventsCardTheme",
    noticesAndEventsCardTheme,
  );

  if (prefs.getBool("chartAnimations") == null) {
    chartAnimations = true;
    await prefs.setBool("chartAnimations", true);
  } else {
    chartAnimations = prefs.getBool("chartAnimations");
  }
  FirebaseCrashlytics.instance.setCustomKey("ChartAnimations", chartAnimations);

  if (prefs.getBool("collapseNotifications") == null) {
    collapseNotifications = true;
    await prefs.setBool("collapseNotifications", true);
  } else {
    collapseNotifications = prefs.getBool("collapseNotifications");
  }

  FirebaseCrashlytics.instance
      .setCustomKey("collapseNotifications", collapseNotifications);
}
