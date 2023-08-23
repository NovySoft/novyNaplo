import 'package:flutter/material.dart';

final ThemeData oledThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Colors.orange,
    secondary: Colors.orange,
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
