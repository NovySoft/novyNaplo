import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("markCalculatorSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 2,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title:
                      Text(getTranslatedString("shouldVirtualMarksCollapse")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      setState(() {
                        globals.shouldVirtualMarksCollapse = switchOn;
                      });
                      await globals.prefs
                          .setBool("shouldVirtualMarksCollapse", switchOn);
                      FirebaseCrashlytics.instance
                          .setCustomKey("shouldVirtualMarksCollapse", switchOn);
                    },
                    value: globals.shouldVirtualMarksCollapse,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  //! NOT A REAL TRADEMARK, IT'S A JOKE
                  title: Text("Lőrinc™ " + getTranslatedString("mode")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      setState(() {
                        globals.calcLorincMode = switchOn;
                      });
                      await globals.prefs.setBool("calcLorincMode", switchOn);
                      FirebaseCrashlytics.instance
                          .setCustomKey("calcLorincMode", switchOn);
                    },
                    value: globals.calcLorincMode,
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
