import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';

class FormKey {
  static final formKey = GlobalKey<FormState>(debugLabel: '_FormKey');
}

TextEditingController extraSpaceUnderStatController =
    TextEditingController(text: globals.extraSpaceUnderStat.toString());

class StatisticSettings extends StatefulWidget {
  @override
  _StatisticSettingsState createState() => _StatisticSettingsState();
}

class _StatisticSettingsState extends State<StatisticSettings> {
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
    else if (globals.statisticsCardTheme == "Dark") {
      globals.statisticsCardTheme = "Subject";
      FirebaseCrashlytics.instance.setCustomKey(
        "statisticsCardTheme",
        globals.statisticsCardTheme,
      );
      globals.prefs.setString(
        "statisticsCardTheme",
        globals.statisticsCardTheme,
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
        title: Text(getTranslatedString("statisticSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 5,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("${getTranslatedString("markCountChart")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Kör diagram",
                        child: Text(
                          getTranslatedString("pieChart"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Oszlop diagram",
                        child: Text(
                          getTranslatedString("barChart"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      setState(() {
                        FirebaseCrashlytics.instance
                            .setCustomKey("howManyGraph", value);
                        globals.prefs.setString("howManyGraph", value);
                        globals.howManyGraph = value;
                      });
                    },
                    value: globals.howManyGraph,
                  ),
                );
                break;
              case 1:
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                          "${getTranslatedString("statisticsCardColor")}:"),
                      trailing: DropdownButton<String>(
                        items: _dropDownItems,
                        onChanged: (String value) async {
                          FirebaseCrashlytics.instance.setCustomKey(
                            "statisticsCardTheme",
                            value,
                          );
                          globals.prefs.setString("statisticsCardTheme", value);
                          setState(() {
                            globals.statisticsCardTheme = value;
                          });
                          if (globals.statisticsCardTheme != "Dark" &&
                              globals.statisticsTextColSubject) {
                            globals.prefs.setBool(
                              "statisticsTextColSubject",
                              false,
                            );
                            FirebaseCrashlytics.instance.setCustomKey(
                              "statisticsTextColSubject",
                              false,
                            );
                            setState(() {
                              globals.statisticsTextColSubject = false;
                            });
                          }
                        },
                        value: globals.statisticsCardTheme,
                      ),
                    ),
                    globals.statisticsCardTheme == "Dark"
                        ? Divider()
                        : SizedBox(height: 0, width: 0),
                    globals.statisticsCardTheme == "Dark"
                        ? ListTile(
                            leading: FractionallySizedBox(
                              widthFactor: 0.8,
                              child: Text(
                                  "${getTranslatedString("textColSubject")}:"),
                            ),
                            trailing: Switch(
                              value: globals.statisticsTextColSubject,
                              onChanged: (switchVal) {
                                globals.prefs.setBool(
                                  "statisticsTextColSubject",
                                  switchVal,
                                );
                                FirebaseCrashlytics.instance.setCustomKey(
                                  "statisticsTextColSubject",
                                  switchVal,
                                );
                                setState(() {
                                  globals.statisticsTextColSubject = switchVal;
                                });
                              },
                            ),
                          )
                        : SizedBox(height: 0, width: 0),
                  ],
                );
                break;
              case 2:
                return ListTile(
                  title: Text("${getTranslatedString("colorAv")}:"),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      setState(() {
                        globals.colorAvsInStatisctics = switchOn;
                      });
                      globals.prefs.setBool("colorAvsInStatisctics", switchOn);
                    },
                    value: globals.colorAvsInStatisctics,
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Text(
                      "${getTranslatedString("extraSpaceUnderStat")} (1-500px):"),
                  trailing: SizedBox(
                    width: 50,
                    child: Form(
                      key: FormKey.formKey,
                      child: TextFormField(
                        controller: extraSpaceUnderStatController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslatedString("cantLeaveEmpty");
                          }
                          if (value.length > 6) {
                            return getTranslatedString(
                              "mustBeBeetween1and500",
                            );
                          }
                          if (int.parse(value) > 500 || int.parse(value) <= 0) {
                            return getTranslatedString("mustBeBeetween1and500");
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (String input) async {
                          if (FormKey.formKey.currentState.validate()) {
                            setState(() {
                              globals.extraSpaceUnderStat = int.parse(input);
                            });
                            globals.prefs.setInt(
                                "extraSpaceUnderStat", int.parse(input));
                            FirebaseCrashlytics.instance.setCustomKey(
                                "extraSpaceUnderStat", int.parse(input));
                          }
                        },
                      ),
                    ),
                  ),
                );
                break;
              case 4:
                return Column(
                  children: [
                    SizedBox(height: 5),
                    Text(
                      "${getTranslatedString('splitText')} ${globals.splitChartLength}",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Slider(
                      value: globals.splitChartLength.toDouble(),
                      onChanged: (newValue) {
                        setState(() {
                          globals.splitChartLength = newValue.toInt();
                        });
                      },
                      onChangeEnd: (endValue) {
                        globals.prefs.setInt(
                          "splitChartLength",
                          endValue.toInt(),
                        );
                      },
                      min: 5,
                      max: 30,
                      divisions: 25,
                      label: globals.splitChartLength.toStringAsFixed(0),
                    ),
                  ],
                );
                break;
              default:
                return SizedBox(height: 100, width: 10);
            }
          }),
    );
  }
}
