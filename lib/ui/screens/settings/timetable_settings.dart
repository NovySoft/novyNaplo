import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';

class TimetableSettings extends StatefulWidget {
  @override
  _TimetableSettingsState createState() => _TimetableSettingsState();
}

class _TimetableSettingsState extends State<TimetableSettings> {
  List<DropdownMenuItem<String>> _dropDownItems = [
    DropdownMenuItem(
      value: "Véletlenszerű",
      child: Text(
        getTranslatedString("random"),
      ),
    ),
    DropdownMenuItem(
      value: "Subject",
      child: Text(
        getTranslatedString("subject"),
      ),
    ),
  ];

  @override
  void initState() {
    if (globals.darker)
      _dropDownItems.insert(
        2,
        DropdownMenuItem(
          value: "Dark",
          child: Text(
            getTranslatedString("dark"),
          ),
        ),
      );
    else if (globals.timetableCardTheme == "Dark") {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("timetableSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 2 + (globals.timetableCardTheme == "Dark" ? 1 : 0),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("${getTranslatedString("timetableSubtitle")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Tanterem",
                        child: Text(
                          getTranslatedString("classroom"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Óra témája",
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
                        value: "Kezdés-Bejezés",
                        child: Text(
                          getTranslatedString("startStop"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Időtartam",
                        child: Text(
                          getTranslatedString("period"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      FirebaseCrashlytics.instance
                          .setCustomKey("lessonCardSubtitle", value);
                      globals.prefs.setString("lessonCardSubtitle", value);
                      setState(() {
                        globals.lessonCardSubtitle = value;
                      });
                    },
                    value: globals.lessonCardSubtitle,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text("${getTranslatedString("timetableCardTheme")}:"),
                  trailing: DropdownButton<String>(
                    items: _dropDownItems,
                    onChanged: (String value) async {
                      FirebaseCrashlytics.instance.setCustomKey(
                        "timetableCardTheme",
                        value,
                      );
                      globals.prefs.setString(
                        "timetableCardTheme",
                        value,
                      );
                      setState(() {
                        globals.timetableCardTheme = value;
                      });
                      if (value != "Dark" && globals.timetableTextColSubject) {
                        globals.prefs.setBool(
                          "timetableTextColSubject",
                          false,
                        );
                        FirebaseCrashlytics.instance.setCustomKey(
                          "timetableTextColSubject",
                          false,
                        );
                        setState(() {
                          globals.timetableTextColSubject = false;
                        });
                      }
                    },
                    value: globals.timetableCardTheme,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  leading: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Text("${getTranslatedString("textColSubject")}:"),
                  ),
                  trailing: Switch(
                    value: globals.timetableTextColSubject,
                    onChanged: (switchVal) {
                      globals.prefs.setBool(
                        "timetableTextColSubject",
                        switchVal,
                      );
                      FirebaseCrashlytics.instance.setCustomKey(
                        "timetableTextColSubject",
                        switchVal,
                      );
                      setState(() {
                        globals.timetableTextColSubject = switchVal;
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
