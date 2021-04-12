import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

class NoticesAndEventsSettings extends StatefulWidget {
  @override
  _NoticesAndEventsSettingsState createState() =>
      _NoticesAndEventsSettingsState();
}

class _NoticesAndEventsSettingsState extends State<NoticesAndEventsSettings> {
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
    else if (globals.noticesAndEventsCardTheme == "Dark") {
      globals.noticesAndEventsCardTheme = "Véletlenszerű";
      FirebaseCrashlytics.instance.setCustomKey(
        "noticesAndEventsCardTheme",
        globals.noticesAndEventsCardTheme,
      );
      globals.prefs.setString(
        "noticesAndEventsCardTheme",
        globals.noticesAndEventsCardTheme,
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
        title: Text(getTranslatedString("noticesAndEventsSettings")),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: 1,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ListTile(
                title: Text(
                  "${getTranslatedString("noticesAndEventsCardColor")}:",
                ),
                trailing: DropdownButton<String>(
                  items: _dropDownItems,
                  onChanged: (String value) async {
                    FirebaseCrashlytics.instance.setCustomKey(
                      "noticesAndEventsCardTheme",
                      value,
                    );
                    globals.prefs.setString("noticesAndEventsCardTheme", value);
                    setState(() {
                      globals.noticesAndEventsCardTheme = value;
                    });
                  },
                  value: globals.noticesAndEventsCardTheme,
                ),
              );
              break;
            default:
              return SizedBox(
                height: 10,
                width: 10,
              );
          }
        },
      ),
    );
  }
}
