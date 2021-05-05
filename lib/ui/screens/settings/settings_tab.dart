import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/ui/screens/settings/firebase_settings.dart';
import 'package:novynaplo/ui/screens/settings/subjNickname_settings.dart';
import 'package:novynaplo/ui/screens/settings/timetable_settings.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/login_page.dart' as login;
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/config.dart' as config;
import 'examsSettings.dart';
import 'noticesAndEvents_settings.dart';
import 'calculator_settings.dart';
import 'developer_settings.dart';
import 'homework_settings.dart';
import 'marksTab_settings.dart';
import 'networkAndNotification_settings.dart';
import 'statistics_settings.dart';
import 'subjectColorPicker.dart';
import 'ui_settings.dart';

//TODO: Make settings more user friendly
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
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsTab.title),
      ),
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: GlobalDrawer.getDrawer(SettingsTab.tag, context),
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
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: 16,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
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
                        ),
                        SizedBox(height: 1, width: 5),
                        Icon(
                          MdiIcons.translate,
                        ),
                      ],
                    ),
                    label: Text(
                      'UI ${getTranslatedString("settings")}',
                    )),
              ),
            ),
          );
        } else if (index == 1) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
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
                    ),
                    label: Text(
                      getTranslatedString("marksTabSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 2) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimetableSettings()),
                      );
                    },
                    icon: Icon(
                      Icons.today,
                    ),
                    label: Text(
                      getTranslatedString("timetableSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 3) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExamSettingsTab()),
                      );
                    },
                    icon: Icon(
                      MdiIcons.clipboardText,
                    ),
                    label: Text(
                      getTranslatedString("examSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 4) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeworkSettingsTab()),
                      );
                    },
                    icon: Icon(
                      MdiIcons.bagPersonalOutline,
                    ),
                    label: Text(
                      getTranslatedString("homeworkSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 5) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticesAndEventsSettings(),
                        ),
                      );
                    },
                    icon: Row(
                      children: <Widget>[
                        Icon(Icons.layers),
                        SizedBox(width: 2),
                        Icon(MdiIcons.pin),
                      ],
                    ),
                    label: Text(
                      getTranslatedString("noticesAndEventsSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 6) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StatisticSettings()),
                      );
                    },
                    icon: Icon(
                      MdiIcons.chartScatterPlotHexbin,
                    ),
                    label: Text(
                      getTranslatedString("statisticSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 7) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalculatorSettings()),
                      );
                    },
                    icon: Icon(
                      MdiIcons.calculator,
                    ),
                    label: Text(
                      getTranslatedString("markCalculatorSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 8) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
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
                        Icon(
                          MdiIcons.accessPointNetwork,
                        ),
                        SizedBox(width: 2),
                        Icon(
                          MdiIcons.bellRing,
                        ),
                      ],
                    ),
                    label: Text(
                      getTranslatedString("networkAndNotificationSettings"),
                    )),
              ),
            ),
          );
        } else if (index == 9) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectColorPicker(),
                      ),
                    );
                  },
                  icon: Icon(
                    Ionicons.md_color_palette,
                  ),
                  label: Text(
                    getTranslatedString("subjectColors"),
                  ),
                ),
              ),
            ),
          );
        } else if (index == 10) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectNicknameSettings(
                          isTimetable: false,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    MdiIcons.tagMultiple,
                  ),
                  label: Text(
                    getTranslatedString("subjectNicknames"),
                  ),
                ),
              ),
            ),
          );
        } else if (index == 11) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectNicknameSettings(
                          isTimetable: true,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    MdiIcons.tagMultiple,
                  ),
                  label: Text(
                    getTranslatedString("timetableNicknames"),
                  ),
                ),
              ),
            ),
          );
        } else if (index == 12) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FirebaseSettings(),
                      ),
                    );
                  },
                  icon: Icon(
                    MdiIcons.incognitoCircle,
                  ),
                  label: Text(
                    getTranslatedString("privacySettings"),
                  ),
                ),
              ),
            ),
          );
        } else if (index == 13) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeveloperSettings()),
                      );
                    },
                    icon: Icon(
                      MdiIcons.codeTagsCheck,
                      color: Colors.black,
                    ),
                    label: Text(
                      getTranslatedString("developerSettings"),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )),
              ),
            ),
          );
        } else if (index == 14) {
          return ListTile(
            title: Center(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await _ackAlert(context,
                              "${getTranslatedString("youCanWriteToTheFollowingEmail")}\nnovysoftware@gmail.com");
                        },
                        icon: Icon(
                          MdiIcons.emailSend,
                        ),
                        label: Text(
                          'Bug report (Email)',
                        ))),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          String link = "https://www.facebook.com/NovySoftware";
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
                        icon: Icon(
                          MdiIcons.facebookMessenger,
                        ),
                        label: Text(
                          'Bug report (Messenger)',
                        ))),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
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
                        icon: Icon(
                          Icons.bug_report,
                        ),
                        label: Text(
                          'Bug report (Github)',
                        ))),
              ),
            ])),
          );
        } else if (index == 15) {
          return ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          //FIXME: About dialog still has elevation
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
                        icon: Icon(
                          MdiIcons.cellphoneInformation,
                        ),
                        label: Text(
                          getTranslatedString("appInfo"),
                        ))),
              ),
            ),
          );
        } else if (index == 16) {
          return ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return LogOutDialog();
                              });
                        },
                        icon: Icon(
                          MdiIcons.logout,
                        ),
                        label: Text(
                          getTranslatedString("logOut"),
                        ))),
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
    return new AlertDialog(
      elevation: globals.darker ? 0 : 24,
      title: new Text(getTranslatedString("logOut")),
      content: Text(
        getTranslatedString("sureLogout"),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(getTranslatedString("yes")),
          onPressed: () async {
            FirebaseAnalytics().logEvent(name: "sign_out");
            await globals.resetAllGlobals();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => login.LoginPage()),
              ModalRoute.withName('login-page'),
            );
          },
        ),
        TextButton(
          child: Text(getTranslatedString("no")),
          onPressed: () {
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
        elevation: globals.darker ? 0 : 24,
        title: Text(getTranslatedString("status")),
        content: Text(content),
        actions: <Widget>[
          TextButton(
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
