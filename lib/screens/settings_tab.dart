import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/screens/login_page.dart';
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
import 'dart:async';

String dropDown;
bool switchValue = true;
String onOff = "ki";
String turningOnOff =
    "A reklámok kikapcsolásával elveszed a bevételem egy részét";
const platform = const MethodChannel('consent.sdk/consent');
Future<String> _setConsent(String input) async {
  String result;
  try {
    result = await platform.invokeMethod('setConsent', <String, dynamic>{
      'data': input,
    });
  } on PlatformException catch (e) {
    result = "Failed: '${e.message}'.";
  }
  return result;
}

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                child:
                    Center(child: new Image.asset(menuLogo, fit: BoxFit.fill))),
            ListTile(
              title: Text('Jegyek'),
              leading: Icon(Icons.create),
              onTap: () {
                try {
                  Navigator.pushNamed(context, MarksTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Átlagok'),
              leading: Icon(Icons.all_inclusive),
              onTap: () {
                try {
                  Navigator.pushNamed(context, AvaragesTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Feljegyzések'),
              leading: Icon(Icons.layers),
              onTap: () {
                try {
                  Navigator.pushNamed(context, NoticesTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Grafikonok'),
              leading: Icon(Icons.timeline),
              onTap: () {
                try {
                  Navigator.pushNamed(context, ChartsTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Beállítások'),
              leading: Icon(Icons.settings_applications),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
              onChanged: (bool isOn) {
                setState(() {
                  switchValue = isOn;
                });
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
        textAlign: TextAlign.right,
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
              MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
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
      title: new Text("Figyelmeztetés"),
      content: SizedBox(
        height: 100,
        child: Text(
          turningOnOff,
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
