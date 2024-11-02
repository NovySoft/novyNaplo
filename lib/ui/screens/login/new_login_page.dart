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
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class NewLoginPage extends StatefulWidget {
  static String tag = 'login-page-new';

  const NewLoginPage({
    this.isNewUser = false,
    this.setStateCallback,
    Key key,
  }) : super(key: key);

  final bool isNewUser;
  final Function setStateCallback;

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  bool isFirstUser = false;
  final ScrollController _controller = ScrollController();

  // This is what you're looking for!
  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    DatabaseHelper.getAllUsers()
        .then((value) => isFirstUser = (value.length <= 0));
    super.initState();
  }

  Future<void> handleLogin(String code) async {
    final result = await RequestHandler.newLogin(code).timeout(
      Duration(seconds: 15),
      onTimeout: () {
        return TokenResponse(status: "TIMEOUT");
      },
    );
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

      if ((globals.allUsers ?? []).length == 0) {
        finalUserObject.color = Colors.orange;
      }

      if ((globals.allUsers ?? []).length == 1 &&
          (globals.appBarColoredByUser == false &&
              globals.appBarTextColoredByUser == false)) {
        //Just double checking to avoid a "invisible app bar"
        if (globals.prefs.getBool('appBarColoredByUser') == false &&
            globals.prefs.getBool('appBarTextColoredByUser') == false) {
          if (globals.prefs.getBool('darker')) {
            await globals.prefs.setBool('appBarTextColoredByUser', true);
            globals.appBarTextColoredByUser = true;
          } else {
            await globals.prefs.setBool('appBarColoredByUser', true);
            globals.appBarColoredByUser = true;
          }
        }
      }

      await DatabaseHelper.insertUser(finalUserObject);

      globals.allUsers = await DatabaseHelper.getAllUsers();
      if (widget.setStateCallback != null) {
        widget.setStateCallback();
      }
      if (widget.isNewUser) {
        Navigator.of(context).pop();
      } else {
        await globals.prefs.setBool("isNew", false);
        await globals.prefs.setBool("isOnboradingDone", true);
        // Get highest userid -> newest user
        globals.currentUser = globals.allUsers.reduce((value, element) =>
            (value.userId > element.userId) ? value : element);
        globals.isOnboradingDone = true;
        NotificationHelper.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            .requestPermission();

        Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
      }
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

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        if (isKeyboardVisible) {
          _scrollDown();
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: ListView(
              controller: _controller,
              //physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                logo,
                SizedBox(height: 40.0),
                SizedBox(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: KretaOuathWebView(handleLogin),
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
