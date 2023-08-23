import 'package:flutter/material.dart';

final ThemeData darkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Colors.orange,
    secondary: Colors.orange,
    surface: Color(0xFF2e2e2e),
    background: Color(0xFF2e2e2e),
    error: Colors.red,
    onPrimary: Color(0xFF2e2e2e),
    onSecondary: Color(0xFF2e2e2e),
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Color(0xFF2e2e2e),
  ),
);
