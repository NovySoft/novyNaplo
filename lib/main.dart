import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:novynaplo/helpers/errorHandlingHelper.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/ui/themeHelper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:novynaplo/ui/screens/events_tab.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart';
import 'package:novynaplo/ui/screens/reports_tab.dart';
import 'package:novynaplo/ui/screens/settings/settings_tab.dart';
import 'package:novynaplo/ui/screens/login_page.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart';
import 'package:novynaplo/ui/screens/calculator_tab.dart';
import 'package:novynaplo/ui/screens/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/ui/screens/loading_screen.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/data/database/mainSql.dart' as mainSql;
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:novynaplo/helpers/backgroundFetchHelper.dart'
    as backgroundFetchHelper;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' as foundation show kDebugMode;
import 'package:firebase_performance/firebase_performance.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();
bool isNew = true;
bool isNotNew = false;
int fetchAlarmID = 0; //We're using 0, because why not
Map<String, WidgetBuilder> routes;

class NavigatorKey {
  static final navigatorKey = GlobalKey<NavigatorState>();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await globals.setGlobals();
  if (foundation.kDebugMode) {
    print("Firebase disabled");
    FirebaseAnalytics().setAnalyticsCollectionEnabled(false);
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    FirebasePerformance.instance.setPerformanceCollectionEnabled(false);
  } else {
    FirebaseAnalytics().setAnalyticsCollectionEnabled(true);
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  if (globals.prefs.getBool("isNew") == false) {
    isNew = false;
  } else {
    if (globals.prefs.getBool("isNotNew") != null) {
      if (globals.prefs.getBool("isNotNew") == true) {
        isNotNew = true;
      }
    }
    if (isNotNew == false) {
      String languageCode = Platform.localeName.split('_')[1];
      if (languageCode.toLowerCase().contains('hu')) {
        globals.language = "hu";
      } else {
        globals.language = "en";
      }
      await globals.prefs.setString("FirstOpenTime", DateTime.now().toString());
      await globals.prefs.setString("Language", globals.language);
      await globals.prefs.setBool("getVersion", true);
    }
  }
  routes = <String, WidgetBuilder>{
    "/": (context) =>
        isNew && isNotNew == false ? WelcomeScreen() : LoadingPage(),
    LoginPage.tag: (context) => LoginPage(),
    MarksTab.tag: (context) => MarksTab(),
    SettingsTab.tag: (context) => SettingsTab(),
    NoticesTab.tag: (context) => NoticesTab(),
    StatisticsTab.tag: (context) => StatisticsTab(),
    TimetableTab.tag: (context) => TimetableTab(),
    CalculatorTab.tag: (context) => CalculatorTab(),
    HomeworkTab.tag: (context) => HomeworkTab(),
    ExamsTab.tag: (context) => ExamsTab(),
    EventsTab.tag: (context) => EventsTab(),
    ReportsTab.tag: (context) => ReportsTab(),
  };
  runZonedGuarded(() async {
    await mainSql.initDatabase();
    await notifications.setupNotifications();
    runApp(
      MyApp(),
    );
    globals.fetchPeriod = globals.prefs.getInt("fetchPeriod") == null
        ? 60
        : globals.prefs.getInt("fetchPeriod");
    globals.backgroundFetch = globals.prefs.getBool("backgroundFetch");
    if (globals.backgroundFetch == null ? true : globals.backgroundFetch) {
      globals.backgroundFetchCanWakeUpPhone =
          globals.prefs.getBool("backgroundFetchCanWakeUpPhone") == null
              ? true
              : globals.prefs.getBool("backgroundFetchCanWakeUpPhone");
      await AndroidAlarmManager.initialize();
      await AndroidAlarmManager.cancel(fetchAlarmID);
      await delay(1000);
      await AndroidAlarmManager.periodic(
        Duration(minutes: globals.fetchPeriod),
        fetchAlarmID,
        backgroundFetchHelper.backgroundFetch,
        wakeup: globals.backgroundFetchCanWakeUpPhone,
        rescheduleOnReboot: globals.backgroundFetchCanWakeUpPhone,
      );
    }
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = ErrorMessageBuilder.build();
    globals.globalContext = context;
    return new DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => ThemeHelper().getTheme(brightness),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          builder: (BuildContext context, Widget widget) {
            ErrorWidget.builder = ErrorMessageBuilder.build();
            return widget;
          },
          navigatorKey: NavigatorKey.navigatorKey,
          theme: theme,
          title: 'Novy Napló',
          debugShowCheckedModeBanner: false,
          routes: routes,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
        );
      },
    );
  }
}
