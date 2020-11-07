import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ThemeHelper {
  static List<Color> myGradientList = [
    Colors.pink[300],
    Colors.pink[400],
    Colors.pink,
    Colors.pink[600],
    Colors.pink[700],
    Colors.red[300],
    Colors.red[400],
    Colors.red,
    Colors.red[600],
    Colors.red[700],
    Colors.deepOrange[300],
    Colors.deepOrange[400],
    Colors.deepOrange,
    Colors.deepOrange[600],
    Colors.deepOrange[700],
    Colors.orange[300],
    Colors.orange[400],
    Colors.orange,
    Colors.orange[600],
    Colors.orange[700],
    Colors.orange[800],
    Colors.amber[300],
    Colors.amber[400],
    Colors.amber,
    Colors.amber[600],
    Colors.amber[700],
    Colors.yellow[300],
    Colors.yellow[400],
    Colors.yellow,
    Colors.yellow[600],
    Colors.yellow[700],
    Colors.lime[300],
    Colors.lime[400],
    Colors.lime,
    Colors.lime[600],
    Colors.lime[700],
    Colors.lightGreen[300],
    Colors.lightGreen[400],
    Colors.lightGreen,
    Colors.lightGreen[600],
    Colors.lightGreen[700],
    Colors.green[300],
    Colors.green[400],
    Colors.green,
    Colors.green[600],
    Colors.green[700],
    Colors.teal[200],
    Colors.teal[300],
    Colors.teal[400],
    Colors.teal,
    Colors.teal[600],
    Colors.teal[700],
    Colors.cyan[300],
    Colors.cyan[400],
    Colors.cyan,
    Colors.cyan[600],
    Colors.cyan[700],
    Colors.lightBlue[300],
    Colors.lightBlue[400],
    Colors.lightBlue,
    Colors.lightBlue[600],
    Colors.lightBlue[700],
    Colors.blue[300],
    Colors.blue[400],
    Colors.blue,
    Colors.blue[600],
    Colors.blue[700],
    Colors.indigo[300],
    Colors.indigo[400],
    Colors.indigo,
    Colors.indigo[600],
    Colors.indigo[700],
    Colors.purple[300],
    Colors.purple[400],
    Colors.purple,
    Colors.purple[600],
    Colors.purple[700],
    Colors.deepPurple[300],
    Colors.deepPurple[400],
    Colors.deepPurple,
    Colors.deepPurple[600],
    Colors.deepPurple[700],
  ];

  ThemeData getTheme(brightness) {
    if (brightness == Brightness.dark) {
      FirebaseCrashlytics.instance.setCustomKey("Theme", "Dark");
    } else {
      FirebaseCrashlytics.instance.setCustomKey("Theme", "Bright");
    }
    if (brightness == Brightness.dark) {
      return new ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            },
          ),
          sliderTheme: SliderThemeData(
              activeTickMarkColor: Colors.orange,
              valueIndicatorColor: Colors.black,
              overlayColor: Colors.orange,
              thumbColor: Colors.black,
              activeTrackColor: Colors.orange,
              valueIndicatorTextStyle: TextStyle(color: Colors.orange)),
          dividerColor: Colors.orange,
          textTheme: TextTheme(
              subtitle1: TextStyle(color: Colors.orange),
              headline6: TextStyle(color: Colors.black)),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.orange,
          ),
          backgroundColor: Colors.black,
          primarySwatch: Colors.orange,
          primaryColor: Colors.orange,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(),
          hintColor: Colors.red,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              color: Colors.black,
            ),
            fillColor: Colors.black,
            hintStyle: TextStyle(color: Colors.orange),
            focusColor: Colors.orange,
          ));
    } else {
      return new ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            },
          ),
          sliderTheme: SliderThemeData(
              activeTickMarkColor: Colors.black,
              valueIndicatorColor: Colors.black,
              overlayColor: Colors.black,
              thumbColor: Colors.black,
              activeTrackColor: Colors.black,
              valueIndicatorTextStyle: TextStyle(color: Colors.white)),
          dividerColor: Colors.black,
          textTheme: TextTheme(
              subtitle1: TextStyle(color: Colors.black),
              headline6: TextStyle(color: Colors.black)),
          brightness: Brightness.light,
          primarySwatch: Colors.lightBlue,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.lightBlueAccent,
          ),
          primaryColor: Colors.lightBlueAccent,
          backgroundColor: Colors.white,
          fontFamily: 'Nunito',
          colorScheme: ColorScheme.light(),
          hintColor: Colors.lightBlue,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              color: Colors.blueAccent,
            ),
            fillColor: Colors.black,
            hintStyle: TextStyle(color: Colors.black),
            focusColor: Colors.orange,
          ));
    }
  }

  void changeBrightness(var context, brightness) {
    DynamicTheme.of(context).setBrightness(brightness);
  }

  Color stringToColor(String input) {
    switch (input) {
      case "Red":
        return Colors.red;
        break;
      case "Green":
        return Colors.green;
        break;
      case "lightGreenAccent400":
        return Colors.lightGreenAccent[400];
        break;
      case "Lime":
        return Colors.lime;
        break;
      case "Blue":
        return Colors.blue;
        break;
      case "LightBlue":
        return Colors.lightBlue;
        break;
      case "Teal":
        return Colors.teal;
        break;
      case "Indigo":
        return Colors.indigo;
        break;
      case "Yellow":
        return Colors.yellow;
        break;
      case "Orange":
        return Colors.orange;
        break;
      case "DeepOrange":
        return Colors.deepOrange;
        break;
      case "Pink":
        return Colors.pink;
        break;
      case "Purple":
        return Colors.purple;
        break;
      case "LightPink":
        return Colors.pink[300];
        break;
      default:
        return Colors.transparent;
        break;
    }
  }
}
