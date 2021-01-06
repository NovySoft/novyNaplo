import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/adHelper.dart';
import 'package:novynaplo/helpers/ui/themeHelper.dart';
import 'package:novynaplo/ui/screens/settings/settings_tab.dart';
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
              ? "Világos"
              : "Sötét";
        });
      },
    );
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
        title: Text("UI ${getTranslatedString("settings")}"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4 + globals.adModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text(getTranslatedString("theme")),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Sötét",
                        child: Text(
                          getTranslatedString("dark"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Világos",
                        child: Text(
                          getTranslatedString("bright"),
                        ),
                      ),
                    ],
                    onChanged: (String value) {
                      if (value == "Világos") {
                        ThemeHelper()
                            .changeBrightness(context, Brightness.light);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Bright");
                        FirebaseCrashlytics.instance
                            .setCustomKey("Theme", "Bright");
                      } else {
                        ThemeHelper()
                            .changeBrightness(context, Brightness.dark);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Dark");
                        FirebaseCrashlytics.instance
                            .setCustomKey("Theme", "Dark");
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
                                title: Text(getTranslatedString("status")),
                                content:
                                    Text(getTranslatedString("langRestart")),
                                actions: <Widget>[
                                  FlatButton(
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
                  title: Text(getTranslatedString("ads")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      setState(() {
                        globals.adsEnabled = isOn;
                      });
                      FirebaseCrashlytics.instance.setCustomKey("Ads", isOn);
                      globals.prefs.setBool("ads", isOn);
                      FirebaseAnalytics().setUserProperty(
                          name: "Ads", value: isOn ? "ON" : "OFF");
                      globals.adModifier = isOn ? 1 : 0;
                      if (isOn) {
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return AdsDialog();
                            });
                      } else {
                        adBanner.dispose();
                        showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) {
                            return new AlertDialog(
                              title: new Text(getTranslatedString("ads")),
                              content: Text(
                                getTranslatedString("adsOffRestart"),
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
                          },
                        );
                      }
                    },
                    value: globals.adsEnabled,
                  ),
                );
                break;
              case 3:
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
