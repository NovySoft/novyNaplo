import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/settings/settings_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class MarksTabSettings extends StatefulWidget {
  @override
  _MarksTabSettingsState createState() => _MarksTabSettingsState();
}

class _MarksTabSettingsState extends State<MarksTabSettings> {
  List<DropdownMenuItem<String>> _dropDownItems = [
    DropdownMenuItem(
      value: "Véletlenszerű",
      child: Text(
        getTranslatedString("random"),
      ),
    ),
    DropdownMenuItem(
      value: "Értékelés nagysága",
      child: Text(
        getTranslatedString("evaulationValue"),
      ),
    ),
    DropdownMenuItem(
      value: "Subject",
      child: Text(
        getTranslatedString("subject"),
      ),
    ),
    DropdownMenuItem(
      value: "Egyszínű",
      child: Text(
        getTranslatedString("oneColor"),
      ),
    ),
    DropdownMenuItem(
      value: "Színátmenetes",
      child: Text(
        getTranslatedString("gradient"),
      ),
    ),
  ];

  @override
  void initState() {
    if (globals.markCardTheme == "Egyszínű") {
      indexModifier = 1;
    } else if (globals.markCardTheme == "Dark") {
      indexModifier = 2;
    } else {
      indexModifier = 0;
    }
    if (globals.darker)
      _dropDownItems.insert(
        3,
        DropdownMenuItem(
          value: "Dark",
          child: Text(
            getTranslatedString("dark"),
          ),
        ),
      );
    else if (globals.markCardTheme == "Dark") {
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("marksTabSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 2 + indexModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 1:
                return ListTile(
                  title: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.8,
                    child:
                        Text("${getTranslatedString("marksCardColorTheme")}:"),
                  ),
                  trailing: DropdownButton<String>(
                    items: _dropDownItems,
                    onChanged: (String value) async {
                      FirebaseCrashlytics.instance.setCustomKey(
                        "markCardTheme",
                        value,
                      );
                      globals.prefs.setString(
                        "markCardTheme",
                        value,
                      );
                      setState(() {
                        globals.markCardTheme = value;
                      });
                      if (value == "Egyszínű") {
                        setState(() {
                          indexModifier = 1;
                        });
                      } else if (value == "Dark") {
                        setState(() {
                          indexModifier = 2;
                        });
                      } else {
                        setState(() {
                          indexModifier = 0;
                        });
                      }
                      if (value != "Dark" && globals.marksTextColSubject) {
                        globals.prefs.setBool(
                          "marksTextColSubject",
                          false,
                        );
                        FirebaseCrashlytics.instance.setCustomKey(
                          "marksTextColSubject",
                          false,
                        );
                        setState(() {
                          globals.marksTextColSubject = false;
                        });
                      }
                    },
                    value: globals.markCardTheme,
                  ),
                );
                break;
              case 0:
                return ListTile(
                  title: Text("${getTranslatedString("marksCardSubtitle")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Téma",
                        child: Text(
                          getTranslatedString("theme"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Tanár",
                        child: Text(
                          getTranslatedString("teacher"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Súly",
                        child: Text(
                          getTranslatedString("weight"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Egyszerűsített Dátum",
                        child: Text(
                          getTranslatedString("simplifiedDate"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Pontos Dátum",
                        child: Text(
                          getTranslatedString("exactDate"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      FirebaseCrashlytics.instance
                          .setCustomKey("markCardSubtitle", value);
                      globals.prefs.setString("markCardSubtitle", value);
                      setState(() {
                        globals.markCardSubtitle = value;
                      });
                    },
                    value: globals.markCardSubtitle,
                  ),
                );
                break;
              case 2:
                if (globals.markCardTheme == "Egyszínű")
                  return ListTile(
                    title: Text("${getTranslatedString("marksCardColor")}:"),
                    trailing: DropdownButton<String>(
                      items: [
                        DropdownMenuItem(
                          value: "Red",
                          child: Text(
                            getTranslatedString("red"),
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Green",
                          child: Text(
                            getTranslatedString("green"),
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "lightGreenAccent400",
                          child: Text(
                            getTranslatedString("lightGreen"),
                            style:
                                TextStyle(color: Colors.lightGreenAccent[400]),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Lime",
                          child: Text(
                            getTranslatedString("lime"),
                            style: TextStyle(color: Colors.lime),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Blue",
                          child: Text(
                            getTranslatedString("blue"),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "LightBlue",
                          child: Text(
                            getTranslatedString("lightBlue"),
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Teal",
                          child: Text(
                            getTranslatedString("teal"),
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Indigo",
                          child: Text(
                            getTranslatedString("indigo"),
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Yellow",
                          child: Text(
                            getTranslatedString("yellow"),
                            style: TextStyle(color: Colors.yellow),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Orange",
                          child: Text(
                            getTranslatedString("orange"),
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "DeepOrange",
                          child: Text(
                            getTranslatedString("deepOrange"),
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Pink",
                          child: Text(
                            getTranslatedString("pink"),
                            style: TextStyle(color: Colors.pink),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "LightPink",
                          child: Text(
                            getTranslatedString("lightPink"),
                            style: TextStyle(color: Colors.pink[300]),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Purple",
                          child: Text(
                            getTranslatedString("purple"),
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                      ],
                      onChanged: (String value) async {
                        FirebaseCrashlytics.instance
                            .setCustomKey("markCardConstColor", value);
                        globals.prefs.setString("markCardConstColor", value);
                        setState(() {
                          globals.markCardConstColor = value;
                        });
                      },
                      value: globals.markCardConstColor,
                    ),
                  );
                else
                  return ListTile(
                    leading: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.8,
                      child: Text("${getTranslatedString("textColSubject")}:"),
                    ),
                    trailing: Switch(
                      value: globals.marksTextColSubject,
                      onChanged: (switchVal) {
                        if (switchVal) {
                          globals.prefs.setBool(
                            "marksTextColEval",
                            false,
                          );
                          FirebaseCrashlytics.instance.setCustomKey(
                            "marksTextColEval",
                            false,
                          );
                          setState(() {
                            globals.marksTextColEval = false;
                          });
                        }
                        globals.prefs.setBool(
                          "marksTextColSubject",
                          switchVal,
                        );
                        FirebaseCrashlytics.instance.setCustomKey(
                          "marksTextColSubject",
                          switchVal,
                        );
                        setState(() {
                          globals.marksTextColSubject = switchVal;
                        });
                      },
                    ),
                  );
                break;
              case 3:
                return ListTile(
                  leading: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.8,
                    child: Text("${getTranslatedString("textColEval")}:"),
                  ),
                  trailing: Switch(
                    value: globals.marksTextColEval,
                    onChanged: (switchVal) {
                      if (switchVal) {
                        globals.prefs.setBool(
                          "marksTextColSubject",
                          false,
                        );
                        FirebaseCrashlytics.instance.setCustomKey(
                          "marksTextColSubject",
                          false,
                        );
                        setState(() {
                          globals.marksTextColSubject = false;
                        });
                      }
                      globals.prefs.setBool(
                        "marksTextColEval",
                        switchVal,
                      );
                      FirebaseCrashlytics.instance.setCustomKey(
                        "marksTextColEval",
                        switchVal,
                      );
                      setState(() {
                        globals.marksTextColEval = switchVal;
                      });
                    },
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
