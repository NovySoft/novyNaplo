import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/ui/screens/settings/timetable_settings.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/login_page.dart' as login;
import 'package:novynaplo/main.dart' as main;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/helpers/ui/adHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/config.dart' as config;
import 'calculator_settings.dart';
import 'developer_settings.dart';
import 'homework_settings.dart';
import 'marksTab_settings.dart';
import 'networkAndNotification_settings.dart';
import 'statistics_settings.dart';
import 'ui_settings.dart';

//TODO: Make settings more user friendly
//TODO: Implement: https://pub.dev/packages/flutter_material_color_picker
int indexModifier = 0;

class SettingsTab extends StatefulWidget {
  static String tag = 'settings';
  static String title = getTranslatedString("settings");

  const SettingsTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsTab.title),
      ),
      drawer: getDrawer(SettingsTab.tag, context),
      body: SettingsBody(),
    );
  }
}

class SettingsBody extends StatefulWidget {
  SettingsBody({Key key}) : super(key: key);

  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  void _onLoad(var context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (main.isNew) {
      main.isNew = false;
      setState(() {
        globals.adsEnabled = true;
        globals.adModifier = 1;
      });
      prefs.setBool("ads", true);
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AdsDialog();
          });
    }
    if (globals.markCardTheme == "Egyszínű") {
      setState(() {
        indexModifier = 1;
      });
    } else {
      setState(() {
        indexModifier = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLoad(context));
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: 11 + globals.adModifier,
      // ignore: missing_return
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UIsettings()),
                      );
                    },
                    icon: Row(
                      children: <Widget>[
                        Icon(
                          MdiIcons.televisionGuide,
                          color: Colors.black,
                        ),
                        SizedBox(height: 1, width: 5),
                        Icon(
                          MdiIcons.translate,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    label: Text('UI ${getTranslatedString("settings")}',
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 1) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MarksTabSettings()),
                      );
                    },
                    icon: Icon(
                      Icons.create,
                      color: Colors.black,
                    ),
                    label: Text(getTranslatedString("marksTabSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 2) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimetableSettings()),
                      );
                    },
                    icon: Icon(Icons.today, color: Colors.black),
                    label: Text(getTranslatedString("timetableSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 3) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeworkSettingsTab()),
                      );
                    },
                    icon:
                        Icon(MdiIcons.bagPersonalOutline, color: Colors.black),
                    label: Text(getTranslatedString("homeworkSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 4) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StatisticSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.chartScatterPlotHexbin,
                        color: Colors.black),
                    label: Text(getTranslatedString("statisticSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 5) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalculatorSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.calculator, color: Colors.black),
                    label: Text(getTranslatedString("markCalculatorSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 6) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NetworkAndNotificationSettings()),
                      );
                    },
                    icon: Row(
                      children: <Widget>[
                        Icon(MdiIcons.accessPointNetwork, color: Colors.black),
                        SizedBox(width: 2),
                        Icon(MdiIcons.bellRing, color: Colors.black),
                      ],
                    ),
                    label: Text(
                        getTranslatedString("networkAndNotificationSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 7) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeveloperSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.codeTagsCheck, color: Colors.black),
                    label: Text(getTranslatedString("developerSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 8) {
          return ListTile(
            title: Center(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await _ackAlert(context,
                              "${getTranslatedString("youCanWriteToTheFollowingEmail")}\nnovysoftware@gmail.com");
                        },
                        icon: Icon(MdiIcons.emailSend, color: Colors.black),
                        label: Text('Bug report (Email)',
                            style: TextStyle(color: Colors.black)))),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          String link =
                              "https://github.com/NovySoft/novyNaplo/issues/new/choose";
                          if (await canLaunch(link)) {
                            await launch(link);
                          } else {
                            FirebaseAnalytics().logEvent(
                              name: "LinkFail",
                              parameters: {"link": link},
                            );
                            throw 'Could not launch $link';
                          }
                        },
                        icon: Icon(Icons.bug_report, color: Colors.black),
                        label: Text('Bug report (Github)',
                            style: TextStyle(color: Colors.black)))),
              ),
            ])),
          );
        } else if (index == 9) {
          return ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          showAboutDialog(
                            context: context,
                            applicationName: "Novy Napló",
                            applicationVersion: config.currentAppVersionCode,
                            applicationLegalese:
                                "This application is contributed under the MIT license",
                            applicationIcon: Image.asset(
                              "assets/icon/icon.png",
                              height: 100,
                              width: 100,
                            ),
                          );
                        },
                        icon: Icon(MdiIcons.cellphoneInformation,
                            color: Colors.black),
                        label: Text(getTranslatedString("appInfo"),
                            style: TextStyle(color: Colors.black)))),
              ),
            ),
          );
        } else if (index == 10) {
          return ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return LogOutDialog();
                              });
                        },
                        icon: Icon(MdiIcons.logout, color: Colors.black),
                        label: Text(getTranslatedString("logOut"),
                            style: TextStyle(color: Colors.black)))),
              ),
            ),
          );
        } else {
          return SizedBox(height: 100);
        }
      },
    );
  }
}

class LogOutDialog extends StatefulWidget {
  @override
  _LogOutDialogState createState() => new _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> {
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return new AlertDialog(
      title: new Text(getTranslatedString("logOut")),
      content: Text(
        getTranslatedString("sureLogout"),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(getTranslatedString("yes")),
          onPressed: () async {
            FirebaseAnalytics().logEvent(name: "sign_out");
            globals.resetAllGlobals();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => login.LoginPage()),
              ModalRoute.withName('login-page'),
            );
          },
        ),
        FlatButton(
          child: Text(getTranslatedString("no")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class AdsDialog extends StatefulWidget {
  @override
  _AdsDialogState createState() => new _AdsDialogState();
}

class _AdsDialogState extends State<AdsDialog> {
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return new AlertDialog(
      title: new Text(getTranslatedString("ads")),
      content: Text(
        getTranslatedString("turnOnAds"),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () async {
            globals.adsEnabled = true;
            adBanner.load();
            adBanner.show(
              anchorType: AnchorType.bottom,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

Future<void> _ackAlert(BuildContext context, String content) async {
  return showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(getTranslatedString("status")),
        content: Text(content),
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
