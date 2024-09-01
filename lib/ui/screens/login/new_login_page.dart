import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/helpers/notification/notificationHelper.dart';
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/login/kreta_oauth_webview.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksTab;

class NewLoginPage extends StatefulWidget {
  static String tag = 'login-page-new';
  const NewLoginPage({Key key}) : super(key: key);

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  bool isFirstUser = false;

  @override
  void initState() {
    DatabaseHelper.getAllUsers()
        .then((value) => isFirstUser = (value.length <= 0));
    super.initState();
  }

  Future<void> handleLogin(String code) async {
    print(code);
    final result = await RequestHandler.newLogin(code).timeout(
      Duration(seconds: 15),
      onTimeout: () {
        return TokenResponse(status: "TIMEOUT");
      },
    );
    print(result.status);
    if (result.status == "OK") {
      Student finalUserObject = await RequestHandler.getStudentInfo(
        result.userinfo,
        embedDetails: true,
      );
      finalUserObject.current = isFirstUser;

      List<int> allColors = myListOfRandomColors
          .map(
            (e) => e.value,
          )
          .toList();
      for (Student user in (globals.allUsers ?? [])) {
        allColors.remove(user.color.value);
      }
      if (allColors.length == 0) {
        allColors = myListOfRandomColors
            .map(
              (e) => e.value,
            )
            .toList();
      }
      finalUserObject.color =
          Color(allColors[Random().nextInt(allColors.length)]);
      await DatabaseHelper.insertUser(finalUserObject);
      await globals.prefs.setBool("isNew", false);
      globals.prefs.setBool("isOnboradingDone", true);
      globals.isOnboradingDone = true;
      NotificationHelper.flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .requestPermission();

      Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
    } else if (result.status == "TIMEOUT") {
      ErrorToast.showErrorToast(
        getTranslatedString("timeoutErr"),
      );
    } else {
      //'Handled error'
      ErrorToast.showErrorToastLong(
        context,
        result.status,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 75.0,
          child: Image.asset('assets/home.png')),
    );

    return Scaffold(
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            logo,
            SizedBox(height: 40.0),
            SizedBox(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: KretaOuathWebView(handleLogin),
            ),
          ],
        ),
      ),
    );
  }
}
