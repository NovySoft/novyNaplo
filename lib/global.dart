import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/database/deleteSql.dart' as delSql;

//Variables used globally;
//Session
var dJson; //Student JSON
var avJson; //Avarage JSON
var token; //Bearer token from api
int markCount; //How many marks do we have
int noticesCount; //How many notices do we have
//"Permanent"
String markCardSubtitle; //Marks subtitle
String markCardTheme; //Marks color theme
String markCardConstColor; //If theme is constant what color is it
String lessonCardSubtitle; //Lesson card's subtitle
String loadingText = "Kérlek várj..."; //Betöltő szöveg
String statChart; //Mit kell a statisztikánál mutatni
String howManyGraph; //What should we show? A pie- or a bar-chart
bool adsEnabled; //Do we have to show ads
bool chartAnimations; //Do we need to animate the charts
bool shouldVirtualMarksCollapse = false; //Should we group virtual marks
bool showAllAvsInStats =
    false; //Show all avarages or just the best and the worst?
bool offlineModeDb = true; //Should we store data in the database?
bool backgroundFetch = false; //Should we fetch data in the background?
bool backgroundFetchCanWakeUpPhone =
    true; //Should we wake the phone up to fetch data?
bool backgroundFetchOnCellular = false; //Should we fetch on cellular data
int adModifier = 0;
int extraSpaceUnderStat = 0; //How many extra padding do we need?
int fetchPeriod = 60; //After how many minutes should we fetch the new data?
BuildContext globalContext; //Yes this is a global context variable
bool didFetch = false; //True if we fetched the data, false if we didn't
NotificationAppLaunchDetails
    notificationAppLaunchDetails; //!Doesn't seem to work, but i'll use it nevertheless
int payloadId =
    -1; //Payload id, contains id of the notification we want to show
bool notifications = false; //Should we send notifications
double howLongKeepDataForHw = 7; //How long should we show homeworks (in days)
bool colorAvsInStatisctics =
    true; //Should we color the name of subjects based on their values

void resetAllGlobals() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  delSql.clearAllTables();
  prefs.setString("code", null);
  await prefs.clear();
  prefs.setBool("ads", adsEnabled);
  dJson = null;
  avJson = null;
  token = null;
  markCount = null;
  noticesCount = null;
  didFetch = false;
}

Future<void> setGlobals() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("ads") != null) {
    Crashlytics.instance.setBool("Ads", prefs.getBool("ads"));
    adsEnabled = prefs.getBool("ads");
    if (adsEnabled) adModifier = 1;
  }

  if (prefs.getBool("colorAvsInStatisctics") != null) {
    colorAvsInStatisctics = prefs.getBool("colorAvsInStatisctics");
  } else {
    prefs.setBool("colorAvsInStatisctics", true);
    colorAvsInStatisctics = true;
  }

  if (prefs.getDouble("howLongKeepDataForHw") != null) {
    howLongKeepDataForHw = prefs.getDouble("howLongKeepDataForHw");
  } else {
    prefs.setDouble("howLongKeepDataForHw", 7);
    howLongKeepDataForHw = 7;
  }
  Crashlytics.instance.setDouble("howLongKeepDataForHw", howLongKeepDataForHw);

  if (prefs.getBool("notifications") != null) {
    notifications = prefs.getBool("notifications");
  } else {
    prefs.setBool("notifications", false);
    notifications = false;
  }
  Crashlytics.instance.setBool("notifications", notifications);
  FirebaseAnalytics().setUserProperty(
    name: "Notifications",
    value: notifications ? "ON" : "OFF",
  );

  if (prefs.getBool("offlineModeDb") != null) {
    offlineModeDb = prefs.getBool("offlineModeDb");
  } else {
    prefs.setBool("offlineModeDb", true);
    offlineModeDb = true;
  }
  Crashlytics.instance.setBool("offlineModeDb", offlineModeDb);

  if (prefs.getBool("backgroundFetchOnCellular") != null) {
    backgroundFetchOnCellular = prefs.getBool("backgroundFetchOnCellular");
  } else {
    prefs.setBool("backgroundFetchOnCellular", false);
    backgroundFetchOnCellular = false;
  }
  Crashlytics.instance
      .setBool("backgroundFetchOnCellular", backgroundFetchOnCellular);

  fetchPeriod =
      prefs.getInt("fetchPeriod") == null ? 60 : prefs.getInt("fetchPeriod");
  backgroundFetch = prefs.getBool("backgroundFetch") == null
      ? false
      : prefs.getBool("backgroundFetch");
  Crashlytics.instance.setBool("backgroundFetch", backgroundFetch);
  backgroundFetchCanWakeUpPhone =
      prefs.getBool("backgroundFetchCanWakeUpPhone") == null
          ? true
          : prefs.getBool("backgroundFetchCanWakeUpPhone");
  Crashlytics.instance
      .setBool("backgroundFetchCanWakeUpPhone", backgroundFetchCanWakeUpPhone);

  if (prefs.getString("howManyGraph") == null) {
    howManyGraph = "Kör diagram";
    prefs.setString("howManyGraph", howManyGraph);
  } else {
    howManyGraph = prefs.getString("howManyGraph");
  }
  Crashlytics.instance.setString("howManyGraph", howManyGraph);

  if (prefs.getInt("extraSpaceUnderStat") != null) {
    extraSpaceUnderStat = prefs.getInt("extraSpaceUnderStat");
  }
  Crashlytics.instance.setInt("extraSpaceUnderStat", extraSpaceUnderStat);

  if (prefs.getBool("showAllAvsInStats") == null) {
    showAllAvsInStats = false;
    prefs.setBool("showAllAvsInStats", false);
  } else {
    showAllAvsInStats = prefs.getBool("showAllAvsInStats");
  }
  Crashlytics.instance.setBool("showAllAvsInStats", showAllAvsInStats);

  if (prefs.getBool("shouldVirtualMarksCollapse") == null) {
    shouldVirtualMarksCollapse = false;
    prefs.setBool("shouldVirtualMarksCollapse", false);
  } else {
    shouldVirtualMarksCollapse = prefs.getBool("shouldVirtualMarksCollapse");
  }
  Crashlytics.instance
      .setBool("shouldVirtualMarksCollapse", shouldVirtualMarksCollapse);

  if (prefs.getString("markCardSubtitle") == null && markCardSubtitle == null) {
    markCardSubtitle = "Téma";
    prefs.setString("markCardSubtitle", "Téma");
  } else if (markCardSubtitle == null) {
    markCardSubtitle = prefs.getString("markCardSubtitle");
  }
  Crashlytics.instance.setString("markCardSubtitle", markCardSubtitle);

  if (prefs.getString("markCardConstColor") == null &&
      markCardConstColor == null) {
    markCardConstColor = "Green";
    prefs.setString("markCardConstColor", "Green");
  } else if (markCardConstColor == null) {
    markCardConstColor = prefs.getString("markCardConstColor");
  }
  Crashlytics.instance.setString("markCardConstColor", markCardConstColor);

  if (prefs.getString("lessonCardSubtitle") == null &&
      lessonCardSubtitle == null) {
    lessonCardSubtitle = "Tanterem";
    prefs.setString("lessonCardSubtitle", "Tanterem");
  } else if (lessonCardSubtitle == null) {
    lessonCardSubtitle = prefs.getString("lessonCardSubtitle");
  }
  Crashlytics.instance.setString("lessonCardSubtitle", lessonCardSubtitle);

  if (prefs.getString("markCardTheme") == null && markCardTheme == null) {
    markCardTheme = "Véletlenszerű";
    prefs.setString("markCardTheme", "Véletlenszerű");
  } else if (markCardTheme == null) {
    markCardTheme = prefs.getString("markCardTheme");
  }
  Crashlytics.instance.setString("markCardTheme", markCardTheme);

  if (prefs.getString("statChart") == null && statChart == null) {
    statChart = "Mindent";
    prefs.setString("statChart", "Mindent");
  } else if (statChart == null) {
    statChart = prefs.getString("statChart");
  }
  Crashlytics.instance.setString("statChart", statChart);

  if (prefs.getBool("chartAnimations") == null && chartAnimations == null) {
    chartAnimations = true;
    prefs.setBool("chartAnimations", true);
  } else if (chartAnimations == null) {
    chartAnimations = prefs.getBool("chartAnimations");
  }
  Crashlytics.instance.setBool("ChartAnimations", chartAnimations);
}
