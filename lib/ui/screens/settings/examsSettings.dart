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
      globals.examsCardTheme = "Véletlenszerű";
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
        itemCount: 1,
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
                  },
                  value: globals.examsCardTheme,
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
