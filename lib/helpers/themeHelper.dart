import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class ThemeHelper {
  ThemeData getTheme(brightness) {
    if (brightness == Brightness.dark) {
      return new ThemeData(
          sliderTheme: SliderThemeData(
            activeTickMarkColor: Colors.orange,
            valueIndicatorColor: Colors.black,
            overlayColor: Colors.orange,
            thumbColor: Colors.black,
            activeTrackColor: Colors.orange,
            valueIndicatorTextStyle: TextStyle(color: Colors.orange)
          ),
          dividerColor: Colors.orange,
          textTheme: TextTheme(
            subhead: TextStyle(color: Colors.orange),
            title: TextStyle(color: Colors.black)
          ),
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
          sliderTheme: SliderThemeData(
            activeTickMarkColor: Colors.black,
            valueIndicatorColor: Colors.black,
            overlayColor: Colors.black,
            thumbColor: Colors.black,
            activeTrackColor: Colors.black,
            valueIndicatorTextStyle: TextStyle(color: Colors.white)
          ),
          dividerColor: Colors.black,
          textTheme: TextTheme(
            subhead: TextStyle(color: Colors.black),
            title: TextStyle(color: Colors.black)
          ),
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

  void changeBrightness(var context,brightness) {
    DynamicTheme.of(context).setBrightness(brightness);
  }
}
