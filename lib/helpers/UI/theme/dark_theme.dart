import 'package:flutter/material.dart';

final ThemeData darkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Colors.red,
    secondary: Colors.red,
    surface: Colors.black,
    background: Colors.black,
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.black,
  ),
);
