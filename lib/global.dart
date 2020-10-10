import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/database/deleteSql.dart' as delSql;
import 'dart:io' show Platform;

//Variables used globally;
//* Session
var dJson; //Student JSON
var avJson; //Avarage JSON
var token; //Bearer token from api
DateTime tokenDate; //The 'time' of token fetching
BuildContext globalContext; //Yes this is a global context variable
bool didFetch = false; //True if we fetched the data, false if we didn't
NotificationAppLaunchDetails
    notificationAppLaunchDetails; //!Doesn't seem to work, but i'll use it nevertheless
int payloadId =
    -1; //Payload id, contains id of the notification we want to show
String notifPayload; //Contains the prefix of the notification payload
String
    payloadString; //Used when instead of an integer we use string as payloadId
//* "Permanent"
String markCardSubtitle; //Marks subtitle
String markCardTheme; //Marks color theme
String markCardConstColor; //If theme is constant what color is it
String lessonCardSubtitle; //Lesson card's subtitle
String statChart; //Mit kell a statisztikánál mutatni
String howManyGraph; //What should we show? A pie- or a bar-chart
bool adsEnabled; //Do we have to show ads
bool chartAnimations; //Do we need to animate the charts
bool shouldVirtualMarksCollapse = false; //Should we group virtual marks
bool backgroundFetch = true; //Should we fetch data in the background?
bool backgroundFetchCanWakeUpPhone =
    true; //Should we wake the phone up to fetch data?
bool backgroundFetchOnCellular = false; //Should we fetch on cellular data
bool verCheckOnStart =
    true; //Should we check for updates upon startup, can be slow, but reminds user to update
int adModifier = 0;
int extraSpaceUnderStat = 0; //How many extra padding do we need?
int fetchPeriod = 60; //After how many minutes should we fetch the new data?
bool notifications = true; //Should we send notifications
double howLongKeepDataForHw = 7; //How long should we show homeworks (in days)
bool colorAvsInStatisctics =
    true; //Should we color the name of subjects based on their values
String language =
    "hu"; //Language to show stuff in, defualts to hungarian as you can see

void resetAllGlobals() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  delSql.clearAllTables();
  prefs.setString("code", null);
  await prefs.clear();
  prefs.setBool("ads", adsEnabled);
  prefs.setBool("isNew", true);
  prefs.setBool("isNotNew",
      true); //isNotNew is for users that already loged in, but logged out later
  dJson = null;
  avJson = null;
  token = null;
  didFetch = false;
}

Future<void> setGlobals() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString("FirstOpenTime") == null) {
    await prefs.setString("FirstOpenTime", DateTime.now().toString());
    await prefs.setString("LastAsked", DateTime.now().toString());
  }

  if (prefs.getBool("getVersion") != null) {
    verCheckOnStart = prefs.getBool("getVersion");
  } else {
    prefs.setBool("getVersion", true);
    verCheckOnStart = true;
  }

  if (prefs.getBool("ShouldAsk") == null) {
    await prefs.setBool("ShouldAsk", true);
  }

  if (prefs.getBool("ads") != null) {
    Crashlytics.instance.setBool("Ads", prefs.getBool("ads"));
    adsEnabled = prefs.getBool("ads");
    if (adsEnabled) adModifier = 1;
  }
  if (prefs.getString("Language") != null) {
    language = prefs.getString("Language");
  } else {
    //String countryCode = Platform.localeName.split('_')[0];
    String languageCode = Platform.localeName.split('_')[1];
    if (languageCode.toLowerCase().contains('hu')) {
      language = "hu";
    } else {
      language = "en";
    }
    prefs.setString("Language", language);
  }
  FirebaseAnalytics().setUserProperty(
    name: "Language",
    value: language,
  );
  Crashlytics.instance.setString("Language", language);

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
    prefs.setBool("notifications", true);
    notifications = true;
  }
  Crashlytics.instance.setBool("notifications", notifications);
  FirebaseAnalytics().setUserProperty(
    name: "Notifications",
    value: notifications ? "ON" : "OFF",
  );

  if (prefs.getBool("backgroundFetchOnCellular") != null) {
    backgroundFetchOnCellular = prefs.getBool("backgroundFetchOnCellular");
  } else {
    prefs.setBool("backgroundFetchOnCellular", false);
    backgroundFetchOnCellular = false;
  }
  Crashlytics.instance
      .setBool("backgroundFetchOnCellular", backgroundFetchOnCellular);

  if (prefs.getInt("fetchPeriod") == null) {
    fetchPeriod = 60;
    prefs.setInt("fetchPeriod", 60);
  } else {
    fetchPeriod = prefs.getInt("fetchPeriod");
  }

  if (prefs.getBool("backgroundFetch") == null) {
    backgroundFetch = true;
    prefs.setBool("backgroundFetch", true);
  } else {
    backgroundFetch = prefs.getBool("backgroundFetch");
  }
  Crashlytics.instance.setBool("backgroundFetch", backgroundFetch);

  if (prefs.getBool("backgroundFetchCanWakeUpPhone") == null) {
    backgroundFetchCanWakeUpPhone = true;
    prefs.setBool("backgroundFetchCanWakeUpPhone", true);
  } else {
    backgroundFetchCanWakeUpPhone =
        prefs.getBool("backgroundFetchCanWakeUpPhone");
  }
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
