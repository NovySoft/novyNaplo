import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

//Fixme: "Warnings when disabled"
class FirebaseSettings extends StatefulWidget {
  @override
  _FirebaseSettingsState createState() => _FirebaseSettingsState();
}

class _FirebaseSettingsState extends State<FirebaseSettings> {
  bool _crashlytics = false;
  bool _analytics = false;
  bool _performance = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool _value =
          await FirebasePerformance.instance.isPerformanceCollectionEnabled();
      setState(() {
        _crashlytics =
            FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;
        _analytics = globals.prefs.getBool("AnalyticsEnabled") ?? true;
        _performance = _value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("privacySettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 3,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text(getTranslatedString("Crashlytics")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      if (!switchOn) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: globals.darker ? 0 : 24,
                              title: Text(getTranslatedString("status")),
                              content: SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  Text(getTranslatedString(
                                    "disableCrashlytics",
                                  )),
                                ]),
                              ),
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
                      setState(() {
                        _crashlytics = switchOn;
                      });
                      FirebaseCrashlytics.instance
                          .setCrashlyticsCollectionEnabled(switchOn);
                    },
                    value: _crashlytics,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text(getTranslatedString("Analytics")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      if (!switchOn) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: globals.darker ? 0 : 24,
                              title: Text(getTranslatedString("status")),
                              content: SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  Text(getTranslatedString(
                                    "disableAnalytics",
                                  )),
                                ]),
                              ),
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
                      setState(() {
                        _analytics = switchOn;
                      });
                      FirebaseAnalytics()
                          .setAnalyticsCollectionEnabled(switchOn);
                      await globals.prefs.setBool("AnalyticsEnabled", switchOn);
                    },
                    value: _analytics,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text(getTranslatedString("PerfM")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      if (!switchOn) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: globals.darker ? 0 : 24,
                              title: Text(getTranslatedString("status")),
                              content: SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  Text(getTranslatedString(
                                    "disablePerformance",
                                  )),
                                ]),
                              ),
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
                      setState(() {
                        _performance = switchOn;
                      });
                      FirebasePerformance.instance
                          .setPerformanceCollectionEnabled(switchOn);
                    },
                    value: _performance,
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
