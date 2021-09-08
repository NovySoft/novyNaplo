import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

class ExamSettingsTab extends StatefulWidget {
  @override
  _ExamSettingsTabState createState() => _ExamSettingsTabState();
}

class _ExamSettingsTabState extends State<ExamSettingsTab> {
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
        1,
        DropdownMenuItem(
          value: "Dark",
          child: Text(
            getTranslatedString("dark"),
          ),
        ),
      );
    else if (globals.examsCardTheme == "Dark") {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("examSettings")),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: 1 + (globals.examsCardTheme == "Dark" ? 1 : 0),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ListTile(
                title: Text("${getTranslatedString("examsCardColor")}:"),
                trailing: DropdownButton<String>(
                  items: _dropDownItems,
                  onChanged: (String value) async {
                    FirebaseCrashlytics.instance.setCustomKey(
                      "examsCardTheme",
                      value,
                    );
                    globals.prefs.setString("examsCardTheme", value);
                    setState(() {
                      globals.examsCardTheme = value;
                    });
                    if (value != "Dark" && globals.examsTextColSubject) {
                      globals.prefs.setBool(
                        "examsTextColSubject",
                        false,
                      );
                      FirebaseCrashlytics.instance.setCustomKey(
                        "examsTextColSubject",
                        false,
                      );
                      setState(() {
                        globals.examsTextColSubject = false;
                      });
                    }
                  },
                  value: globals.examsCardTheme,
                ),
              );
              break;
            case 1:
              return ListTile(
                leading: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.8,
                  child: Text("${getTranslatedString("textColSubject")}:"),
                ),
                trailing: Switch(
                  value: globals.examsTextColSubject,
                  onChanged: (switchVal) {
                    globals.prefs.setBool(
                      "examsTextColSubject",
                      switchVal,
                    );
                    FirebaseCrashlytics.instance.setCustomKey(
                      "examsTextColSubject",
                      switchVal,
                    );
                    setState(() {
                      globals.examsTextColSubject = switchVal;
                    });
                  },
                ),
              );
              break;
            default:
              return SizedBox(
                height: 0,
                width: 0,
              );
          }
        },
      ),
    );
  }
}
