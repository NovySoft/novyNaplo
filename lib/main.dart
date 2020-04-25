import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/functions/utils.dart';
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
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:novynaplo/global.dart' as globals;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseAnalytics analytics = FirebaseAnalytics();
final navigatorKey = GlobalKey<NavigatorState>();
bool isNew = true;
int fetchAlarmID = 0; //We're using 0, because why not
BuildContext mainContext;

void main() async {
  //Change to true if needed
  Crashlytics.instance.enableInDevMode = false;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("isNew") == false) {
    isNew = false;
  }
  runZoned(() async {
    runApp(MyApp());
    globals.fetchPeriod = prefs.getInt("fetchPeriod");
    if (prefs.getBool("backgroundFetch")) {
      await AndroidAlarmManager.initialize();
      await AndroidAlarmManager.cancel(fetchAlarmID);
      await sleep(1000);
      await AndroidAlarmManager.periodic(
        Duration(minutes: globals.fetchPeriod),
        fetchAlarmID,
        getMarksInBackground,
        wakeup: globals.backgroundFetchCanWakeUpPhone,
        rescheduleOnReboot: globals.backgroundFetchCanWakeUpPhone,
      );
    }
  }, onError: Crashlytics.instance.recordError);
}

void getMarksInBackground() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print(
      "[$now] Hello, world! isolate=$isolateId function='$getMarksInBackground'");
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
    globals.globalContext = context;
    mainContext = context;
    initializeNotifications();
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

  void initializeNotifications() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    if (payload != null && payload != "teszt") {
      print(payload);
      //TODO MAKE THE ACTUAL PAYLOAD HANDLING HERE
    } else {
      showDialog<void>(
        context: globals.globalContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Státusz'),
            content: Text("Egy teszt értesítést nyomtál meg...\nAmennyiben ez nem így történt jelentsd a hibát"),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
