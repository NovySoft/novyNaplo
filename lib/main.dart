import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/helpers/errorHandlingHelper.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/ui/themeHelper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/ui/screens/absences_tab.dart';
import 'package:novynaplo/ui/screens/events_tab.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart';
import 'package:novynaplo/ui/screens/reports_tab.dart';
import 'package:novynaplo/ui/screens/settings/settings_tab.dart';
import 'package:novynaplo/ui/screens/login/login_page.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart';
import 'package:novynaplo/ui/screens/calculator/calculator_tab.dart';
import 'package:novynaplo/ui/screens/welcome_screen.dart';
import 'package:novynaplo/ui/screens/loading_screen.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/notification/notificationHelper.dart';
import 'package:novynaplo/helpers/backgroundFetchHelper.dart'
    as backgroundFetchHelper;
import 'dart:io' show HttpOverrides, Platform;
import 'package:flutter/foundation.dart' as foundation show kDebugMode;
import 'package:firebase_performance/firebase_performance.dart';
import 'API/certValidation.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
bool isNew = true;
int fetchAlarmID = 0; //We're using 0, because why not
Map<String, WidgetBuilder> routes;

// FIXME: flutter.dev/go/android-splash-migration

class NavigatorKey {
  static final navigatorKey = GlobalKey<NavigatorState>();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await globals.setGlobals();
  if (foundation.kDebugMode) {
    print("Firebase disabled");
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    FirebasePerformance.instance.setPerformanceCollectionEnabled(false);
  }
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    return true;
  };
  if (globals.prefs.getBool("isNew") == false) {
    isNew = false;
  } else {
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
  routes = <String, WidgetBuilder>{
    "/": (context) => isNew ? WelcomeScreen() : LoadingPage(),
    LoginPage.tag: (context) => LoginPage(),
    MarksTab.tag: (context) => MarksTab(false),
    SettingsTab.tag: (context) => SettingsTab(),
    NoticesTab.tag: (context) => NoticesTab(),
    StatisticsTab.tag: (context) => StatisticsTab(),
    TimetableTab.tag: (context) => TimetableTab(),
    CalculatorTab.tag: (context) => CalculatorTab(),
    HomeworkTab.tag: (context) => HomeworkTab(),
    ExamsTab.tag: (context) => ExamsTab(),
    EventsTab.tag: (context) => EventsTab(),
    ReportsTab.tag: (context) => ReportsTab(),
    AbsencesTab.tag: (context) => AbsencesTab(),
    LoadingPage.tag: (context) => LoadingPage(),
  };
  runZonedGuarded(() async {
    await DatabaseHelper.initDatabase();
    await NotificationHelper.setupNotifications();
    HttpOverrides.global = new MyHttpOverrides();
    runApp(
      MyApp(),
    );
    globals.fetchPeriod = globals.fetchPeriod;
    globals.backgroundFetch = globals.backgroundFetch;
    if (globals.backgroundFetch) {
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
    return new DynamicTheme(
      defaultThemeMode: ThemeMode.dark,
      data: (brightness) => ThemeHelper().getTheme(brightness),
      themedWidgetBuilder: (context, mode, theme) {
        return MaterialApp(
          builder: (BuildContext context, Widget widget) {
            ErrorWidget.builder = ErrorMessageBuilder.build();
            return widget;
          },
          navigatorKey: NavigatorKey.navigatorKey,
          theme: theme,
          title: 'Novy Napló',
          debugShowCheckedModeBanner: true,
          routes: routes,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
        );
      },
    );
  }
}
