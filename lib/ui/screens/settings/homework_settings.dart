import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;

class HomeworkSettingsTab extends StatefulWidget {
  @override
  _HomeworkSettingsTabState createState() => _HomeworkSettingsTabState();
}

class _HomeworkSettingsTabState extends State<HomeworkSettingsTab> {
  double keepDataForHw = 7;
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
    else if (globals.homeworkCardTheme == "Dark") {
      globals.homeworkCardTheme = "Értékelés nagysága";
      FirebaseCrashlytics.instance.setCustomKey(
        "homeworkCardTheme",
        globals.homeworkCardTheme,
      );
      globals.prefs.setString(
        "homeworkCardTheme",
        globals.homeworkCardTheme,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        keepDataForHw = globals.prefs.getDouble("howLongKeepDataForHw");
      });
    });
    super.initState();
  }

  void updateHwTab() async {
    homeworkPage.globalHomework = await DatabaseHelper.getAllHomework(
      ignoreDue: false,
    );
    homeworkPage.globalHomework.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("homeworkSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (_, __) => Divider(),
          itemCount: 2,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Column(
                  children: [
                    Text(
                      keepDataForHw >= 0
                          ? getTranslatedString("homeworkKeepFor") +
                              " \n${keepDataForHw.toStringAsFixed(0)} ${getTranslatedString("forDay")}"
                          : getTranslatedString("homeworkKeepFor") +
                              " \n${getTranslatedString("forInfinity")}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    Slider(
                      value: keepDataForHw,
                      onChanged: (newValue) {
                        setState(() {
                          if (newValue.roundToDouble() == 0 ||
                              newValue.roundToDouble() == -0) {
                            keepDataForHw = 0;
                          } else {
                            keepDataForHw = newValue.roundToDouble();
                          }
                        });
                      },
                      onChangeEnd: (newValue) async {
                        setState(() {
                          if (newValue.roundToDouble() == 0 ||
                              newValue.roundToDouble() == -0) {
                            keepDataForHw = 0;
                          } else {
                            keepDataForHw = newValue.roundToDouble();
                          }
                          globals.howLongKeepDataForHw = keepDataForHw;
                          globals.prefs
                              .setDouble("howLongKeepDataForHw", keepDataForHw);
                          FirebaseCrashlytics.instance.setCustomKey(
                              "howLongKeepDataForHw", keepDataForHw);
                        });
                        updateHwTab();
                      },
                      min: -1,
                      max: 15,
                      divisions: 17,
                      label: keepDataForHw.toStringAsFixed(0),
                    ),
                  ],
                );
                break;
              case 1:
                return ListTile(
                  title: Text("${getTranslatedString("homeworkCardColor")}:"),
                  trailing: DropdownButton<String>(
                    items: _dropDownItems,
                    onChanged: (String value) async {
                      FirebaseCrashlytics.instance.setCustomKey(
                        "homeworkCardTheme",
                        value,
                      );
                      globals.prefs.setString("homeworkCardTheme", value);
                      setState(() {
                        globals.homeworkCardTheme = value;
                      });
                    },
                    value: globals.homeworkCardTheme,
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
