import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:novynaplo/functions/colorManager.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/login_page.dart';
FirebaseAnalytics analytics = FirebaseAnalytics();


void main() async {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
  /*Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.contacts]);*/
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    MarksTab.tag: (context) => MarksTab(),
    AvaragesTab.tag: (context) => AvaragesTab(),
    SettingsTab.tag: (context) => SettingsTab(),
  };

  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ColorManager().getTheme(brightness),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            theme: theme,
            title: 'Novy Napló',
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
            routes: routes,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
          );
        });
  }
}
