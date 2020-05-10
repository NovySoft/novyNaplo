import 'dart:typed_data';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/main.dart' as main;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/helpers/themeHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';

final _formKey = GlobalKey<FormState>();
final _formKeyTwo = GlobalKey<FormState>();
String dropDown;
String statDropDown = globals.statChart;
String howManyGraphDropDown = globals.howManyGraph;
String markDropdown = globals.markCardSubtitle;
String lessonDropdown = globals.lessonCardSubtitle;
String markThemeDropdown = globals.markCardTheme;
String constColorDropdown = globals.markCardConstColor;
bool adsSwitch = globals.adsEnabled;
bool animationSwitch = globals.chartAnimations;
bool notificationSwitch = false;
int indexModifier = 0;
bool shouldCollapseSwitch = globals.shouldVirtualMarksCollapse;
bool showAllAvsInStatsSwitch = globals.showAllAvsInStats;
TextEditingController extraSpaceUnderStatController =
    TextEditingController(text: globals.extraSpaceUnderStat.toString());
TextEditingController fetchPeriodController =
    TextEditingController(text: globals.fetchPeriod.toString());

class SettingsTab extends StatefulWidget {
  static String tag = 'settings';
  static const title = 'Beállítások';

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
        adsSwitch = true;
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
    if (Theme.of(context).brightness == Brightness.light) {
      dropDown = "Világos";
    } else {
      dropDown = "Sötét";
    }
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: 9 + globals.adModifier,
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
                    icon: Icon(
                      MdiIcons.televisionGuide,
                      color: Colors.black,
                    ),
                    label: Text('UI beállítások',
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
                    label: Text('Jegyek oldal beállításai',
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
                    label: Text('Órarend beállításai',
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
                            builder: (context) => StatisticSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.chartScatterPlotHexbin,
                        color: Colors.black),
                    label: Text('Statisztika oldal beállításai',
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
                            builder: (context) => CalculatorSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.calculator, color: Colors.black),
                    label: Text('Jegyszámoló oldal beállításai',
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
                    onPressed: null,
                    /*() async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NetworkAndNotificationSettings()),
                      );
                    },*/
                    icon: Row(
                      children: <Widget>[
                        Icon(MdiIcons.accessPointNetwork, color: Colors.black),
                        SizedBox(width: 2),
                        Icon(MdiIcons.bellRing, color: Colors.black),
                      ],
                    ),
                    label: Text('Hálozat és értesítés beállításai',
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
                            builder: (context) => DatabaseSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.databaseEdit, color: Colors.black),
                    label: Text('Adatbázis beállításai',
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 7) {
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
                              "Az alábbi emailra tudsz írni:\nnovynaplo@gmail.com");
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
                            FirebaseAnalytics().logEvent(name: "LinkFail");
                            throw 'Could not launch $link';
                          }
                        },
                        icon: Icon(Icons.bug_report, color: Colors.black),
                        label: Text('Bug report (Github)',
                            style: TextStyle(color: Colors.black)))),
              ),
            ])),
          );
        } else if (index == 8) {
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
                        label: Text('Kijelentkezés',
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

class TimetableSettings extends StatefulWidget {
  @override
  _TimetableSettingsState createState() => _TimetableSettingsState();
}

class _TimetableSettingsState extends State<TimetableSettings> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Órarend beállításai"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 1,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("Órarend alcím:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Tanterem",
                        child: Text(
                          "Tanterem",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Óra témája",
                        child: Text(
                          "Óra témája",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Tanár",
                        child: Text(
                          "Tanár",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Kezdés-Bejezés",
                        child: Text(
                          "Kezdés-Bejezés",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Időtartam",
                        child: Text(
                          "Időtartam",
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance
                          .setString("lessonCardSubtitle", value);
                      prefs.setString("lessonCardSubtitle", value);
                      globals.lessonCardSubtitle = value;
                      setState(() {
                        lessonDropdown = value;
                      });
                    },
                    value: lessonDropdown,
                  ),
                );
                break;
              default:
            }
            return SizedBox(height: 10, width: 10);
          }),
    );
  }
}

class MarksTabSettings extends StatefulWidget {
  @override
  _MarksTabSettingsState createState() => _MarksTabSettingsState();
}

class _MarksTabSettingsState extends State<MarksTabSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Jegyek oldal beállításai"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 2 + indexModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 1:
                return ListTile(
                  title: Text("Jegykártya színtéma:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Véletlenszerű",
                        child: Text(
                          "Véletlenszerű",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Értékelés nagysága",
                        child: Text(
                          "Értékelés nagysága",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Egyszínű",
                        child: Text(
                          "Egyszínű",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Színátmenetes",
                        child: Text(
                          "Színátmenetes",
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance.setString("markCardTheme", value);
                      prefs.setString("markCardTheme", value);
                      globals.markCardTheme = value;
                      setState(() {
                        markThemeDropdown = value;
                      });
                      if (value == "Egyszínű") {
                        setState(() {
                          indexModifier = 1;
                        });
                      } else {
                        setState(() {
                          indexModifier = 0;
                        });
                      }
                    },
                    value: markThemeDropdown,
                  ),
                );
                break;
              case 0:
                return ListTile(
                  title: Text("Jegy alcím:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Téma",
                        child: Text(
                          "Téma",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Tanár",
                        child: Text(
                          "Tanár",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Súly",
                        child: Text(
                          "Súly",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Egyszerűsített Dátum",
                        child: Text(
                          "Egyszerűsített Dátum",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Pontos Dátum",
                        child: Text(
                          "Pontos Dátum",
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance.setString("markCardSubtitle", value);
                      prefs.setString("markCardSubtitle", value);
                      globals.markCardSubtitle = value;
                      setState(() {
                        markDropdown = value;
                      });
                    },
                    value: markDropdown,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text("Jegykártyák színe:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Red",
                        child: Text(
                          "Piros",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Green",
                        child: Text(
                          "Zöld",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "lightGreenAccent400",
                        child: Text(
                          "Világos zöld",
                          style: TextStyle(color: Colors.lightGreenAccent[400]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Lime",
                        child: Text(
                          "Lime",
                          style: TextStyle(color: Colors.lime),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Blue",
                        child: Text(
                          "Kék",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "LightBlue",
                        child: Text(
                          "Világos kék",
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Teal",
                        child: Text(
                          "Zöldes kék",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Indigo",
                        child: Text(
                          "Indigó kék",
                          style: TextStyle(color: Colors.indigo),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Yellow",
                        child: Text(
                          "Sárga",
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Orange",
                        child: Text(
                          "Narancs",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "DeepOrange",
                        child: Text(
                          "Sötét narancs",
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Pink",
                        child: Text(
                          "Rózsaszín",
                          style: TextStyle(color: Colors.pink),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "LightPink",
                        child: Text(
                          "Világos Rózsaszín",
                          style: TextStyle(color: Colors.pink[300]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Purple",
                        child: Text(
                          "Lila",
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance
                          .setString("markCardConstColor", value);
                      prefs.setString("markCardConstColor", value);
                      globals.markCardConstColor = value;
                      setState(() {
                        constColorDropdown = value;
                      });
                    },
                    value: constColorDropdown,
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
            }
          }),
    );
  }
}

class UIsettings extends StatefulWidget {
  @override
  _UIsettingsState createState() => _UIsettingsState();
}

class _UIsettingsState extends State<UIsettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("UI beállításaok"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 3,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("Téma:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Sötét",
                        child: Text(
                          "Sötét",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Világos",
                        child: Text(
                          "Világos",
                        ),
                      ),
                    ],
                    onChanged: (String value) {
                      if (value == "Világos") {
                        ThemeHelper()
                            .changeBrightness(context, Brightness.light);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Bright");
                        Crashlytics.instance.setString("Theme", "Bright");
                      } else {
                        ThemeHelper()
                            .changeBrightness(context, Brightness.dark);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Dark");
                        Crashlytics.instance.setString("Theme", "Dark");
                      }
                      setState(() {
                        dropDown = value;
                      });
                    },
                    value: dropDown,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text("Reklámok"),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        adsSwitch = isOn;
                      });
                      Crashlytics.instance.setBool("Ads", isOn);
                      if (isOn) {
                        FirebaseAnalytics()
                            .setUserProperty(name: "Ads", value: "ON");
                        prefs.setBool("ads", true);
                        globals.adsEnabled = true;
                        globals.adModifier = 1;
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return AdsDialog();
                            });
                      } else {
                        FirebaseAnalytics()
                            .setUserProperty(name: "Ads", value: "OFF");
                        prefs.setBool("ads", false);
                        globals.adsEnabled = false;
                        globals.adModifier = 0;
                        adBanner.dispose();
                        showDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) {
                              return new AlertDialog(
                                title: new Text("Reklámok"),
                                content: Text(
                                  "A reklámok kikapcsolásához indítsd újra az applikációt",
                                  textAlign: TextAlign.left,
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    value: adsSwitch,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text("Chart animációk:"),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        animationSwitch = switchOn;
                        globals.chartAnimations = switchOn;
                      });
                      Crashlytics.instance.setBool("ChartAnimations", switchOn);
                      if (switchOn) {
                        FirebaseAnalytics().setUserProperty(
                            name: "ChartAnimations", value: "YES");
                        prefs.setBool("chartAnimations", true);
                      } else {
                        FirebaseAnalytics().setUserProperty(
                            name: "ChartAnimations", value: "NO");
                        prefs.setBool("chartAnimations", false);
                      }
                    },
                    value: animationSwitch,
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
            }
          }),
    );
  }
}

class StatisticSettings extends StatefulWidget {
  @override
  _StatisticSettingsState createState() => _StatisticSettingsState();
}

class _StatisticSettingsState extends State<StatisticSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Statisztika oldal beállításai"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("Statisztika mutató:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Mindent",
                        child: Text(
                          "Mindent",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Összesített",
                        child: Text(
                          "Összesített",
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        Crashlytics.instance.setString("statChart", value);
                        prefs.setString("statChart", value);
                        globals.statChart = value;
                        statDropDown = value;
                      });
                    },
                    value: statDropDown,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text("Jegyek számának mutatója:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Kör diagram",
                        child: Text(
                          "Kör diagram",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Oszlop diagram",
                        child: Text(
                          "Oszlop diagram",
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        Crashlytics.instance.setString("howManyGraph", value);
                        prefs.setString("howManyGraph", value);
                        globals.howManyGraph = value;
                        howManyGraphDropDown = value;
                      });
                    },
                    value: howManyGraphDropDown,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text("Összes átlag mutatása:"),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        showAllAvsInStatsSwitch = switchOn;
                        globals.showAllAvsInStats = switchOn;
                      });
                      prefs.setBool("showAllAvsInStats", switchOn);
                      Crashlytics.instance
                          .setBool("showAllAvsInStats", switchOn);
                    },
                    value: showAllAvsInStatsSwitch,
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Text("Grafikon alatti extra hely (1-500px):"),
                  trailing: SizedBox(
                    width: 50,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: extraSpaceUnderStatController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Ezt nem hagyhatod üresen';
                          }
                          if (int.parse(value) > 500 || int.parse(value) <= 0) {
                            return "Az értéknek 1 és 500 között kell lenie";
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (String input) async {
                          if (_formKey.currentState.validate()) {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              globals.extraSpaceUnderStat = int.parse(input);
                            });
                            prefs.setInt(
                                "extraSpaceUnderStat", int.parse(input));
                            Crashlytics.instance.setInt(
                                "extraSpaceUnderStat", int.parse(input));
                          }
                        },
                      ),
                    ),
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
            }
          }),
    );
  }
}

class CalculatorSettings extends StatefulWidget {
  @override
  _CalculatorSettingsState createState() => _CalculatorSettingsState();
}

class _CalculatorSettingsState extends State<CalculatorSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Jegyszámoló oldal beállításai"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 1,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("Virtuális jegyek összevonása"),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        shouldCollapseSwitch = switchOn;
                        globals.shouldVirtualMarksCollapse = switchOn;
                      });
                      prefs.setBool("shouldVirtualMarksCollapse", switchOn);
                      Crashlytics.instance
                          .setBool("shouldVirtualMarksCollapse", switchOn);
                    },
                    value: shouldCollapseSwitch,
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
            }
          }),
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
      title: new Text("Kijelentkezés"),
      content: Text(
        "Biztosan ki szeretnél jelentkezni?",
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Igen'),
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
          child: Text('Nem'),
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
      title: new Text("Reklámok"),
      content: Text(
        "A reklámok bekapcsolásával elfogadod az Admob privacy policity és azt hogy a Google bizonyos információkat gyűjthet rólad (és oszthat meg harmadik félel),és azt is elfogadod, hogy ezen információk segítségével számodra releváns hírdetések fognak megjelenni.",
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
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Státusz'),
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

class NetworkAndNotificationSettings extends StatefulWidget {
  @override
  _NetworkAndNotificationSettingsState createState() =>
      _NetworkAndNotificationSettingsState();
}

class _NetworkAndNotificationSettingsState
    extends State<NetworkAndNotificationSettings> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Hálózat és értesítés beállításai"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 2 + (globals.backgroundFetch ? 2 : 0),
          // ignore: missing_return
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
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
                            //TODO group notifications
                            var vibrationPattern = new Int64List(4);
                            vibrationPattern[0] = 0;
                            vibrationPattern[1] = 1000;
                            vibrationPattern[2] = 5000;
                            vibrationPattern[3] = 2000;
                            var androidPlatformChannelSpecifics =
                                new AndroidNotificationDetails(
                              'novynaplo01',
                              'novynaplo',
                              'Channel for sending novyNaplo notifications',
                              importance: Importance.Max,
                              priority: Priority.High,
                              vibrationPattern: vibrationPattern,
                              color: const Color.fromARGB(255, 255, 165, 0),
                              visibility: NotificationVisibility.Public,
                              ledColor: Colors.orange,
                              ledOnMs: 1000,
                              ledOffMs: 1000,
                              enableLights: true,
                            );
                            var iOSPlatformChannelSpecifics =
                                new IOSNotificationDetails();
                            var platformChannelSpecifics =
                                new NotificationDetails(
                                    androidPlatformChannelSpecifics,
                                    iOSPlatformChannelSpecifics);
                            await main.flutterLocalNotificationsPlugin.show(
                              1,
                              'Teszt értesítés',
                              'Így fog kinézni egy értesítés...',
                              platformChannelSpecifics,
                              payload: 'teszt',
                            );
                          },
                          icon: Icon(
                            MdiIcons.bellRing,
                            color: Colors.black,
                          ),
                          label: Text('Teszt értesítés küldése',
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text("Háttér lekérések"),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        globals.backgroundFetch = isOn;
                        prefs.setBool("backgroundFetch", isOn);
                        Crashlytics.instance.setBool("backgroundFetch", isOn);
                      });
                      if (isOn) {
                        await AndroidAlarmManager.cancel(main.fetchAlarmID);
                        Crashlytics.instance.log(
                            "Canceled alarm: " + main.fetchAlarmID.toString());
                        await sleep(1500);
                        main.fetchAlarmID++;
                        await AndroidAlarmManager.periodic(
                          Duration(minutes: globals.fetchPeriod),
                          main.fetchAlarmID,
                          main.getMarksInBackground,
                          wakeup: globals.backgroundFetchCanWakeUpPhone,
                          rescheduleOnReboot:
                              globals.backgroundFetchCanWakeUpPhone,
                        );
                      } else {
                        await AndroidAlarmManager.cancel(main.fetchAlarmID);
                        Crashlytics.instance.log(
                            "Canceled alarm: " + main.fetchAlarmID.toString());
                        await sleep(1500);
                        main.fetchAlarmID++;
                      }
                    },
                    value: globals.backgroundFetch,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text("Automatikus lekérések időköze (30-500perc):"),
                  trailing: SizedBox(
                    width: 50,
                    child: Form(
                      key: _formKeyTwo,
                      child: TextFormField(
                        controller: fetchPeriodController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Ezt nem hagyhatod üresen';
                          }
                          if (int.parse(value) > 500 || int.parse(value) < 30) {
                            return "Az értéknek 30 és 500 között kell lenie";
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (String input) async {
                          if (_formKeyTwo.currentState.validate()) {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setInt("fetchPeriod", int.parse(input));
                            globals.fetchPeriod = int.parse(input);
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            Crashlytics.instance.log("Canceled alarm: " +
                                main.fetchAlarmID.toString());
                            await sleep(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              main.getMarksInBackground,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Text("A lekérés felkeltheti a telefont (ajánlott)"),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        globals.backgroundFetchCanWakeUpPhone = isOn;
                        prefs.setBool("backgroundFetchCanWakeUpPhone", isOn);
                        Crashlytics.instance
                            .setBool("backgroundFetchCanWakeUpPhone", isOn);
                      });
                      if (isOn) {
                        await AndroidAlarmManager.cancel(main.fetchAlarmID);
                        Crashlytics.instance.log(
                            "Canceled alarm: " + main.fetchAlarmID.toString());
                        await sleep(1500);
                        main.fetchAlarmID++;
                        await AndroidAlarmManager.periodic(
                          Duration(minutes: globals.fetchPeriod),
                          main.fetchAlarmID,
                          main.getMarksInBackground,
                          wakeup: globals.backgroundFetchCanWakeUpPhone,
                          rescheduleOnReboot:
                              globals.backgroundFetchCanWakeUpPhone,
                        );
                      } else {
                        await AndroidAlarmManager.cancel(main.fetchAlarmID);
                        Crashlytics.instance.log(
                            "Canceled alarm: " + main.fetchAlarmID.toString());
                        await sleep(1500);
                        main.fetchAlarmID++;
                        await AndroidAlarmManager.periodic(
                          Duration(minutes: globals.fetchPeriod),
                          main.fetchAlarmID,
                          main.getMarksInBackground,
                          wakeup: globals.backgroundFetchCanWakeUpPhone,
                          rescheduleOnReboot:
                              globals.backgroundFetchCanWakeUpPhone,
                        );
                      }
                    },
                    value: globals.backgroundFetchCanWakeUpPhone,
                  ),
                );
                break;
            }
            return SizedBox(height: 10, width: 10);
          }),
    );
  }
}

class DatabaseSettings extends StatefulWidget {
  @override
  _DatabaseSettingsState createState() => _DatabaseSettingsState();
}

class _DatabaseSettingsState extends State<DatabaseSettings> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Adatbázis beállításai"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 2,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "SQLITE adatbázis",
                          style: new TextStyle(fontSize: 30),
                        ),
                        Text(
                          "Csak haladóknak",
                          style: new TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 1:
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
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return AlertDialog(
                                  title: new Text("Törlés"),
                                  content: Text(
                                    "Biztosan ki szeretnéd törölni az adatbázisokat?\nEz nem fordítható vissza",
                                    textAlign: TextAlign.left,
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Igen',
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () async {
                                        FirebaseAnalytics()
                                            .logEvent(name: "clear_database");
                                        Crashlytics.instance
                                            .log("clear_database");
                                        await clearAllTables();
                                        Navigator.of(context).pop();
                                        _ackAlert(context,
                                            "Adatbázis sikeresen törölve");
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Nem'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            MdiIcons.databaseRemove,
                            color: Colors.black,
                          ),
                          label: Text('Táblák kiürítése',
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
                break;
            }
          }),
    );
  }
}
