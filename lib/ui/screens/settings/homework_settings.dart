import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/database/homework.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;

class HomeworkSettingsTab extends StatefulWidget {
  @override
  _HomeworkSettingsTabState createState() => _HomeworkSettingsTabState();
}

class _HomeworkSettingsTabState extends State<HomeworkSettingsTab> {
  double keepDataForHw = 7;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        keepDataForHw = globals.prefs.getDouble("howLongKeepDataForHw");
      });
    });
    super.initState();
  }

  void updateHwTab() async {
    homeworkPage.globalHomework = await getAllHomework(ignoreDue: false);
    homeworkPage.globalHomework.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    homeworkPage.colors = getRandomColors(homeworkPage.globalHomework.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("homeworkSettings")),
      ),
      body: ListView(
        children: <Widget>[
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
                globals.prefs.setDouble("howLongKeepDataForHw", keepDataForHw);
                FirebaseCrashlytics.instance
                    .setCustomKey("howLongKeepDataForHw", keepDataForHw);
              });
              updateHwTab();
            },
            min: -1,
            max: 15,
            divisions: 17,
            label: keepDataForHw.toStringAsFixed(0),
          ),
        ],
      ),
    );
  }
}
