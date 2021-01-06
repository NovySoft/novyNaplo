import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';

class TimetableSettings extends StatefulWidget {
  @override
  _TimetableSettingsState createState() => _TimetableSettingsState();
}

class _TimetableSettingsState extends State<TimetableSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("timetableSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 1,
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
              default:
            }
            return SizedBox(height: 10, width: 10);
          }),
    );
  }
}
