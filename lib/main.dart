import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:novynaplo/helpers/themeHelper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/statistics_tab.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:novynaplo/screens/calculator_tab.dart';
import 'package:novynaplo/screens/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/screens/loading_screen.dart';
import 'package:novynaplo/screens/homework_tab.dart';
import 'package:novynaplo/helpers/chartHelper.dart' as chart;

FirebaseAnalytics analytics = FirebaseAnalytics();
final navigatorKey = GlobalKey<NavigatorState>();
bool isNew = true;

void main() async {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("isNew") == false) {
    isNew = false;
  }
  runZoned(() {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    MarksTab.tag: (context) => MarksTab(),
    AvaragesTab.tag: (context) => AvaragesTab(),
    SettingsTab.tag: (context) => SettingsTab(),
    NoticesTab.tag: (context) => NoticesTab(),
    StatisticsTab.tag: (context) => StatisticsTab(),
    TimetableTab.tag: (context) => TimetableTab(),
    CalculatorTab.tag: (context) => CalculatorTab(),
    HomeworkTab.tag: (context) => HomeworkTab(),
  };

  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => ThemeHelper().getTheme(brightness),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            theme: theme,
            title: 'Novy Napló',
            debugShowCheckedModeBanner: false,
            home: isNew ? WelcomeScreen() : LoadingPage(),
            routes: routes,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
          );
        });
  }
}
