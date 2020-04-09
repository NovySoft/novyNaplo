import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Variables used globally;
//Session
var dJson; //Student JSON
var avJson; //Avarage JSON
var token; //Bearer token from api
int avarageCount; //How many subjects do we have
int markCount; //How many marks do we have
int noticesCount; //How many notices do we have
List<Homework> globalHomework = []; //Global homework
//"Permanent"
String markCardSubtitle; //Marks subtitle
String markCardTheme; //Marks color theme
String markCardConstColor; //If theme is constant what color is it
String lessonCardSubtitle; //Lesson card's subtitle
String loadingText = "Kérlek várj..."; //Betöltő szöveg
String statChart; //Mit kell a statisztikánál mutatni
bool adsEnabled; //Do we have to show ads
bool chartAnimations; //Do we need to animate the charts
int adModifier = 0;

void resetAllGlobals() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("code", null);
  prefs.clear();
  prefs.setBool("ads", adsEnabled);
  dJson = null;
  avJson = null;
  token = null;
  avarageCount = null;
  markCount = null;
  noticesCount = null;
}

void setGlobals() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.getBool("ads") != null) Crashlytics.instance.setString("markCardSubtitle", markCardSubtitle);

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
