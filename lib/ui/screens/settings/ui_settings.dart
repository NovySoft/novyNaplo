import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/themeHelper.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

String dropDown;

class UIsettings extends StatefulWidget {
  @override
  _UIsettingsState createState() => _UIsettingsState();
}

class _UIsettingsState extends State<UIsettings> {
  Widget status = Icon(
    MdiIcons.closeCircle, /*check*/
  );

  @override
  void initState() {
    if (globals.markCardTheme == "Dark" &&
        globals.timetableCardTheme == "Dark" &&
        globals.homeworkCardTheme == "Dark" &&
        globals.examsCardTheme == "Dark" &&
        globals.noticesAndEventsCardTheme == "Dark" &&
        globals.statisticsCardTheme == "Dark") {
      status = Icon(MdiIcons.check);
    } else {
      status = Icon(
        MdiIcons.closeCircle, /*check*/
      );
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(() {
          dropDown = DynamicTheme.of(context).themeMode == ThemeMode.light
              ? "Light"
              : DynamicTheme.of(context).themeMode == ThemeMode.dark &&
                      globals.darker
                  ? "Darker"
                  : "Dark";
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setDarkCards() {
    //Marks
    globals.markCardTheme = "Dark";
    FirebaseCrashlytics.instance.setCustomKey(
      "markCardTheme",
      globals.markCardTheme,
    );
    globals.prefs.setString(
      "markCardTheme",
      globals.markCardTheme,
    );
    //Marks text
    globals.marksTextColEval = true;
    FirebaseCrashlytics.instance.setCustomKey(
      "marksTextColEval",
      globals.marksTextColEval,
    );
    globals.prefs.setBool(
      "marksTextColEval",
      globals.marksTextColEval,
    );
    if (globals.marksTextColSubject) {
      globals.marksTextColSubject = false;
      FirebaseCrashlytics.instance.setCustomKey(
        "marksTextColSubject",
        globals.marksTextColSubject,
      );
      globals.prefs.setBool(
        "marksTextColSubject",
        globals.marksTextColSubject,
      );
    }
    //Timetable
    globals.timetableCardTheme = "Dark";
    FirebaseCrashlytics.instance.setCustomKey(
      "timetableCardTheme",
      globals.timetableCardTheme,
    );
    globals.prefs.setString(
      "timetableCardTheme",
      globals.timetableCardTheme,
    );
    //Timetable text
    globals.timetableTextColSubject = true;
    FirebaseCrashlytics.instance.setCustomKey(
      "timetableTextColSubject",
      globals.timetableTextColSubject,
    );
    globals.prefs.setBool(
      "timetableTextColSubject",
      globals.timetableTextColSubject,
    );
    //Homework
    globals.homeworkCardTheme = "Dark";
    FirebaseCrashlytics.instance.setCustomKey(
      "homeworkCardTheme",
      globals.homeworkCardTheme,
    );
    globals.prefs.setString(
      "homeworkCardTheme",
      globals.homeworkCardTheme,
    );
    //Homework text
    globals.homeworkTextColSubject = true;
    FirebaseCrashlytics.instance.setCustomKey(
      "homeworkTextColSubject",
      globals.homeworkTextColSubject,
    );
    globals.prefs.setBool(
      "homeworkTextColSubject",
      globals.homeworkTextColSubject,
    );
    //Exams
    globals.examsCardTheme = "Dark";
    FirebaseCrashlytics.instance.setCustomKey(
      "examsCardTheme",
      globals.examsCardTheme,
    );
    globals.prefs.setString(
      "examsCardTheme",
      globals.examsCardTheme,
    );
    //Exams text
    globals.examsTextColSubject = true;
    FirebaseCrashlytics.instance.setCustomKey(
      "examsTextColSubject",
      globals.examsTextColSubject,
    );
    globals.prefs.setBool(
      "examsTextColSubject",
      globals.examsTextColSubject,
    );
    //Notices and events
    globals.noticesAndEventsCardTheme = "Dark";
    FirebaseCrashlytics.instance.setCustomKey(
      "noticesAndEventsCardTheme",
      globals.noticesAndEventsCardTheme,
    );
    globals.prefs.setString(
      "noticesAndEventsCardTheme",
      globals.noticesAndEventsCardTheme,
    );
    //Statistics
    globals.statisticsCardTheme = "Dark";
    FirebaseCrashlytics.instance.setCustomKey(
      "statisticsCardTheme",
      globals.statisticsCardTheme,
    );
    globals.prefs.setString(
      "statisticsCardTheme",
      globals.statisticsCardTheme,
    );
    //Statistics text
    globals.statisticsTextColSubject = true;
    FirebaseCrashlytics.instance.setCustomKey(
      "statisticsTextColSubject",
      globals.statisticsTextColSubject,
    );
    globals.prefs.setBool(
      "statisticsTextColSubject",
      globals.statisticsTextColSubject,
    );
    // App bar
    globals.appBarColoredByUser = false;
    globals.prefs.setBool(
      "appBarColoredByUser",
      globals.appBarColoredByUser,
    );
    globals.appBarTextColoredByUser = true;
    globals.prefs.setBool(
      "appBarTextColoredByUser",
      globals.appBarTextColoredByUser,
    );
  }

  void disableDarkCards() {
    //Marks card
    if (globals.markCardTheme == "Dark") {
      globals.markCardTheme = "Értékelés nagysága";
      FirebaseCrashlytics.instance.setCustomKey(
        "markCardTheme",
        globals.markCardTheme,
      );
      globals.prefs.setString(
        "markCardTheme",
        globals.markCardTheme,
      );
    }
    //Marks card text
    if (globals.marksTextColSubject) {
      globals.marksTextColSubject = false;
      FirebaseCrashlytics.instance.setCustomKey(
        "marksTextColSubject",
        globals.marksTextColSubject,
      );
      globals.prefs.setBool(
        "marksTextColSubject",
        globals.marksTextColSubject,
      );
    }
    if (globals.marksTextColEval) {
      globals.marksTextColEval = false;
      FirebaseCrashlytics.instance.setCustomKey(
        "marksTextColEval",
        globals.marksTextColEval,
      );
      globals.prefs.setBool(
        "marksTextColEval",
        globals.marksTextColEval,
      );
    }
    //Timetable card
    if (globals.timetableCardTheme == "Dark") {
      globals.timetableCardTheme = "Subject";
      FirebaseCrashlytics.instance.setCustomKey(
        "timetableCardTheme",
        globals.timetableCardTheme,
      );
      globals.prefs.setString(
        "timetableCardTheme",
        globals.timetableCardTheme,
      );
    }
    //Timetable text
    if (globals.timetableTextColSubject) {
      globals.timetableTextColSubject = false;
      FirebaseCrashlytics.instance.setCustomKey(
        "timetableTextColSubject",
        globals.timetableTextColSubject,
      );
      globals.prefs.setBool(
        "timetableTextColSubject",
        globals.timetableTextColSubject,
      );
    }
    //Homework card
    if (globals.homeworkCardTheme == "Dark") {
      globals.homeworkCardTheme = "Subject";
      FirebaseCrashlytics.instance.setCustomKey(
        "homeworkCardTheme",
        globals.homeworkCardTheme,
      );
      globals.prefs.setString(
        "homeworkCardTheme",
        globals.homeworkCardTheme,
      );
    }
    //Homework card text
    if (globals.homeworkTextColSubject) {
      globals.homeworkTextColSubject = false;
      FirebaseCrashlytics.instance.setCustomKey(
        "homeworkTextColSubject",
        globals.homeworkTextColSubject,
      );
      globals.prefs.setBool(
        "homeworkTextColSubject",
        globals.homeworkTextColSubject,
      );
    }
    //Exam card
    if (globals.examsCardTheme == "Dark") {
      globals.examsCardTheme = "Subject";
      FirebaseCrashlytics.instance.setCustomKey(
        "examsCardTheme",
        globals.examsCardTheme,
      );
      globals.prefs.setString(
        "examsCardTheme",
        globals.examsCardTheme,
      );
    }
    //Exams card text
    if (globals.examsTextColSubject) {
      globals.examsTextColSubject = false;
      FirebaseCrashlytics.instance.setCustomKey(
        "examsTextColSubject",
        globals.examsTextColSubject,
      );
      globals.prefs.setBool(
        "examsTextColSubject",
        globals.examsTextColSubject,
      );
    }
    //Notices and events card
    if (globals.noticesAndEventsCardTheme == "Dark") {
      globals.noticesAndEventsCardTheme = "Véletlenszerű";
      FirebaseCrashlytics.instance.setCustomKey(
        "noticesAndEventsCardTheme",
        globals.noticesAndEventsCardTheme,
      );
      globals.prefs.setString(
        "noticesAndEventsCardTheme",
        globals.noticesAndEventsCardTheme,
      );
    }
    //Statistics
    if (globals.statisticsCardTheme == "Dark") {
      globals.statisticsCardTheme = "Subject";
      FirebaseCrashlytics.instance.setCustomKey(
        "statisticsCardTheme",
        globals.statisticsCardTheme,
      );
      globals.prefs.setString(
        "statisticsCardTheme",
        globals.statisticsCardTheme,
      );
    }
    //Statistics card text
    if (globals.statisticsTextColSubject) {
      globals.statisticsTextColSubject = false;
      FirebaseCrashlytics.instance.setCustomKey(
        "statisticsTextColSubject",
        globals.statisticsTextColSubject,
      );
      globals.prefs.setBool(
        "statisticsTextColSubject",
        globals.statisticsTextColSubject,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UI ${getTranslatedString("settings")}"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 5 + (globals.darker ? 1 : 0),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text(getTranslatedString("theme")),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Dark",
                        child: Text(
                          getTranslatedString("dark"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Darker",
                        child: Text(
                          getTranslatedString("darker"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Light",
                        child: Text(
                          getTranslatedString("bright"),
                        ),
                      ),
                    ],
                    onChanged: (String value) {
                      if (value == "Light") {
                        globals.prefs.setBool("darker", false);
                        globals.darker = false;
                        ThemeHelper()
                            .changeBrightness(context, ThemeMode.light);
                        FirebaseAnalytics.instance
                            .setUserProperty(name: "Theme", value: "Bright");
                        FirebaseCrashlytics.instance
                            .setCustomKey("Theme", "Bright");
                      } else if (value == "Dark") {
                        //Update button status
                        if (globals.markCardTheme == "Dark" &&
                            globals.timetableCardTheme == "Dark" &&
                            globals.homeworkCardTheme == "Dark" &&
                            globals.examsCardTheme == "Dark" &&
                            globals.noticesAndEventsCardTheme == "Dark" &&
                            globals.statisticsCardTheme == "Dark") {
                          status = Icon(MdiIcons.check);
                        } else {
                          status = Icon(
                            MdiIcons.closeCircle, /*check*/
                          );
                        }
                        //Update prefs
                        globals.prefs.setBool("darker", false);
                        globals.darker = false;
                        ThemeHelper().changeBrightness(context, ThemeMode.dark);
                        FirebaseAnalytics.instance
                            .setUserProperty(name: "Theme", value: "Dark");
                        FirebaseCrashlytics.instance
                            .setCustomKey("Theme", "Dark");
                      } else if (value == "Darker") {
                        globals.prefs.setBool("darker", true);
                        globals.darker = true;
                        ThemeHelper().changeBrightness(context, ThemeMode.dark);
                        FirebaseAnalytics.instance
                            .setUserProperty(name: "Theme", value: "Darker");
                        FirebaseCrashlytics.instance
                            .setCustomKey("Theme", "Darker");
                      }
                      if (!globals.darker) disableDarkCards();
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
                  title: Text("Nyelv (language):"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "hu",
                        child: Text(
                          getTranslatedString("hu"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "en",
                        child: Text(
                          getTranslatedString("en"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      await globals.prefs.setString("Language", value);
                      await FirebaseAnalytics.instance.setUserProperty(
                        name: "Language",
                        value: value,
                      );
                      FirebaseCrashlytics.instance
                          .setCustomKey("Language", value);
                      if (globals.language != value) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => UIsettings(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                        setState(() {
                          globals.language = value;
                        });
                        await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return WillPopScope(
                              onWillPop: () async {
                                return false;
                                //Don't let the user exit without pressing ok
                                //Else it would cause globalkey issues
                                //BUG: fix this issue
                                //! Severity: high
                                //! Fix complexity: high
                              },
                              child: AlertDialog(
                                elevation: globals.darker ? 0 : 24,
                                title: Text(getTranslatedString("status")),
                                content:
                                    Text(getTranslatedString("langRestart")),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Ok'),
                                    onPressed: null,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    value: globals.language,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text(getTranslatedString("chartAnimations")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      setState(() {
                        globals.chartAnimations = switchOn;
                      });
                      FirebaseCrashlytics.instance
                          .setCustomKey("ChartAnimations", switchOn);
                      if (switchOn) {
                        FirebaseAnalytics.instance.setUserProperty(
                            name: "ChartAnimations", value: "YES");
                        globals.prefs.setBool("chartAnimations", true);
                      } else {
                        FirebaseAnalytics.instance.setUserProperty(
                            name: "ChartAnimations", value: "NO");
                        globals.prefs.setBool("chartAnimations", false);
                      }
                    },
                    value: globals.chartAnimations,
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Text(getTranslatedString("appBarColoredByUser")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      setState(() {
                        globals.appBarColoredByUser = switchOn;
                      });
                      if (switchOn) {
                        globals.prefs.setBool("appBarColoredByUser", true);
                        setState(() {
                          globals.appBarTextColoredByUser = false;
                          globals.prefs
                              .setBool("appBarTextColoredByUser", false);
                        });
                      } else {
                        globals.prefs.setBool("appBarColoredByUser", false);
                      }
                      DynamicTheme.of(context).setThemeMode(
                        DynamicTheme.of(context).themeMode,
                      );
                    },
                    value: globals.appBarColoredByUser,
                  ),
                );
                break;
              case 4:
                return ListTile(
                  title: Text(getTranslatedString("appBarTextColoredByUser")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      setState(() {
                        globals.appBarTextColoredByUser = switchOn;
                      });
                      if (switchOn) {
                        globals.prefs.setBool("appBarTextColoredByUser", true);
                        setState(() {
                          globals.appBarColoredByUser = false;
                          globals.prefs.setBool("appBarColoredByUser", false);
                        });
                      } else {
                        globals.prefs.setBool("appBarTextColoredByUser", false);
                      }
                      DynamicTheme.of(context).setThemeMode(
                        DynamicTheme.of(context).themeMode,
                      );
                    },
                    value: globals.appBarTextColoredByUser,
                  ),
                );
                break;
              case 5:
                return ListTile(
                  title: Center(
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
                          setState(() {
                            status = SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            );
                          });
                          await Future.delayed(
                            Duration(milliseconds: 250),
                            () => setDarkCards(),
                          );
                          setState(() {
                            status = Icon(
                              MdiIcons.check,
                            );
                          });
                        },
                        icon: status,
                        label: Text(
                          getTranslatedString("forceDarkCards"),
                        ),
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
