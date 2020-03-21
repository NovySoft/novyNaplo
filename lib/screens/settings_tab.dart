import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/main.dart' as main;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/helpers/themeHelper.dart';

String dropDown;
String markDropdown = globals.markCardSubtitle;
String lessonDropdown = globals.lessonCardSubtitle;
String markThemeDropdown = globals.markCardTheme;
String constColorDropdown = globals.markCardConstColor;
bool adsSwitch = globals.adsEnabled;
bool notificationSwitch = false;
int indexModifier = 0;

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
    if (Theme.of(context).brightness == Brightness.light) {
      dropDown = "Világos";
    } else {
      dropDown = "Sötét";
    }
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: 7 + indexModifier,
      // ignore: missing_return
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
                prefs.setString("markCardSubtitle", value);
                globals.markCardSubtitle = value;
                setState(() {
                  markDropdown = value;
                });
              },
              value: markDropdown,
            ),
          );
        } else if (index == 2) {
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
                prefs.setString("lessonCardSubtitle", value);
                globals.lessonCardSubtitle = value;
                setState(() {
                  lessonDropdown = value;
                });
              },
              value: lessonDropdown,
            ),
          );
        } else if (index == 3) {
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
        } else if (indexModifier == 1 && index == 4) {
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
                prefs.setString("markCardConstColor", value);
                globals.markCardConstColor = value;
                setState(() {
                  constColorDropdown = value;
                });
              },
              value: constColorDropdown,
            ),
          );
        } else if (index == 4 + indexModifier) {
          return ListTile(
            title: Text("Reklámok"),
            trailing: Switch(
              onChanged: (bool isOn) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                setState(() {
                  adsSwitch = isOn;
                });
                if (isOn) {
                  FirebaseAnalytics().setUserProperty(name: "Ads", value: "ON");
                  prefs.setBool("ads", true);
                  globals.adsEnabled = true;
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
        } else if (index == 5 + indexModifier) {
          return ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Háttérlekérések"),
                Text("Értesítések"),
              ],
            ),
            trailing: Switch(
              onChanged: null,
              /*
              onChanged: (bool switchOn) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                setState(() {
                  switchTwoValue = switchOn;
                });
                if (switchOn) {
                  print("ON");
                  FirebaseAnalytics().setUserProperty(name: "Notifications", value: "YES");
                  prefs.setBool("Notifications", true);
                } else {
                  print("OFF");
                  FirebaseAnalytics().setUserProperty(name: "Notifications", value: "NO");
                  prefs.setBool("Notifications", false);
                }
              },*/
              value: notificationSwitch,
            ),
          );
        } else if (index == 6 + indexModifier) {
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
