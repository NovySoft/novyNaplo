import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/helpers/themeHelper.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/screens/charts_tab.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/screens/calculator_tab.dart';
import 'dart:async';

String dropDown;
bool switchValue = login.adsEnabled;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsTab.title),
      ),
      drawer: getDrawer(SettingsTab.tag,context),
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
    if (prefs.getBool("ads") == null) {
      prefs.setBool("ads", true);
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AdsDialog();
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
    if (Theme.of(context).brightness == Brightness.light) {
      dropDown = "Világos";
    } else {
      dropDown = "Sötét";
    }
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: 3,
      itemBuilder: (context, index) {
        if (index == 0) {
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
                  ThemeHelper().changeBrightness(context, Brightness.light);
                  FirebaseAnalytics()
                      .setUserProperty(name: "Theme", value: "Bright");
                } else {
                  ThemeHelper().changeBrightness(context, Brightness.dark);
                  FirebaseAnalytics()
                      .setUserProperty(name: "Theme", value: "Dark");
                }
                setState(() {
                  dropDown = value;
                });
              },
              value: dropDown,
            ),
          );
        } else if (index == 1) {
          return ListTile(
            title: Text("Reklámok"),
            trailing: Switch(
              onChanged: (bool isOn) async{
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  switchValue = isOn;
                });
                if (isOn) {
                  FirebaseAnalytics().setUserProperty(name: "Ads", value: "ON");
                  prefs.setBool("ads", true);
                  login.adsEnabled = true;
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
                  login.adsEnabled = false;
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
              value: switchValue,
            ),
          );
        } else if (index == 2) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
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
              padding: EdgeInsets.all(1),
              child:
                  Text('Kijelentkezés', style: TextStyle(color: Colors.black)),
            ),
          );
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
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => login.LoginPage()),
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
