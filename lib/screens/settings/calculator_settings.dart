import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorSettings extends StatefulWidget {
  @override
  _CalculatorSettingsState createState() => _CalculatorSettingsState();
}

class _CalculatorSettingsState extends State<CalculatorSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("markCalculatorSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 1,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title:
                      Text(getTranslatedString("shouldVirtualMarksCollapse")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        globals.shouldVirtualMarksCollapse = switchOn;
                      });
                      prefs.setBool("shouldVirtualMarksCollapse", switchOn);
                      FirebaseCrashlytics.instance
                          .setCustomKey("shouldVirtualMarksCollapse", switchOn);
                    },
                    value: globals.shouldVirtualMarksCollapse,
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
