import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/themeHelper.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

String dropDown;

class UIsettings extends StatefulWidget {
  @override
  _UIsettingsState createState() => _UIsettingsState();
}

class _UIsettingsState extends State<UIsettings> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(() {
          dropDown = Theme.of(context).brightness == Brightness.light
              ? "Light"
              : Theme.of(context).brightness == Brightness.dark &&
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
    //Timetable card
    if (globals.timetableCardTheme == "Dark") {
      globals.timetableCardTheme = "Véletlenszerű";
      FirebaseCrashlytics.instance.setCustomKey(
        "timetableCardTheme",
        globals.timetableCardTheme,
      );
      globals.prefs.setString(
        "timetableCardTheme",
        globals.timetableCardTheme,
      );
    }
    //Homework card
    if (globals.homeworkCardTheme == "Dark") {
      globals.homeworkCardTheme = "Véletlenszerű";
      FirebaseCrashlytics.instance.setCustomKey(
        "homeworkCardTheme",
        globals.homeworkCardTheme,
      );
      globals.prefs.setString(
        "homeworkCardTheme",
        globals.homeworkCardTheme,
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
          itemCount: 4,
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
                            .changeBrightness(context, Brightness.light);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Bright");
                        FirebaseCrashlytics.instance
                            .setCustomKey("Theme", "Bright");
                      } else if (value == "Dark") {
                        globals.prefs.setBool("darker", false);
                        globals.darker = false;
                        ThemeHelper()
                            .changeBrightness(context, Brightness.dark);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Dark");
                        FirebaseCrashlytics.instance
                            .setCustomKey("Theme", "Dark");
                      } else if (value == "Darker") {
                        globals.prefs.setBool("darker", true);
                        globals.darker = true;
                        ThemeHelper()
                            .changeBrightness(context, Brightness.dark);
                        FirebaseAnalytics()
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
                      await FirebaseAnalytics().setUserProperty(
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
                        FirebaseAnalytics().setUserProperty(
                            name: "ChartAnimations", value: "YES");
                        globals.prefs.setBool("chartAnimations", true);
                      } else {
                        FirebaseAnalytics().setUserProperty(
                            name: "ChartAnimations", value: "NO");
                        globals.prefs.setBool("chartAnimations", false);
                      }
                    },
                    value: globals.chartAnimations,
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
