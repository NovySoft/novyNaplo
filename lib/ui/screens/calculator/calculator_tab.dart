import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/calculator.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/calculator/whatIf_module.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/helpers/ui/textColor/drawerText.dart';
import 'calculator_module.dart';

//TODO: Add option to add mark calculator marks to what if
//TODO: add performance to mark calculator and also make averages a before and after gauge pair
List<String> dropdownValues = [];
String dropdownValue = dropdownValues[0];
List<CalculatorData> averageList = [];
int currentIndex = 0;

num currCount = 0;
num currSum = 0;

bool fixedPhysics = false;

final List<Tab> calcTabs = <Tab>[
  Tab(text: getTranslatedString("markCalc"), icon: Icon(MdiIcons.calculator)),
  Tab(
      text: "${getTranslatedString("whatIf")}?",
      icon: Icon(MdiIcons.headQuestion)),
];
List<Evals> currentSubject = [];

class CalculatorTab extends StatefulWidget {
  static String tag = 'calculator';
  static String title = getTranslatedString("markCalc");

  @override
  CalculatorTabState createState() => CalculatorTabState();
}

class CalculatorTabState extends State<CalculatorTab>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown MarkCalculator");
    //Set dropdown to item 0
    if (marksPage.allParsedByDate.length != 0) {
      dropdownValue = dropdownValues[0];
      currentIndex = 0;
      currCount = averageList[0].count;
      currSum = averageList[0].sum;
      currentSubject = stats.allParsedSubjects[0];
      text1 = "";
      turesHatar = 1;
      elakErni = 5.0;
    }

    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }

  void callSetState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: CustomDrawer(CalculatorTab.tag),
      appBar: AppBar(
        backgroundColor:
            globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor: getDrawerForeground(),
        title: Text(CalculatorTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: calcTabs,
          labelColor: getTabForeground(),
        ),
      ),
      body: TabBarView(
          physics: fixedPhysics
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          controller: _tabController,
          children: calcTabs.map((Tab tab) {
            if (marksPage.allParsedByDate.length == 0) {
              return noMarks();
            }
            if (tab.text == getTranslatedString("markCalc")) {
              return CalculatorModule(callSetState);
            } else {
              return WhatIFModule(callSetState);
            }
          }).toList()),
    );
  }
}

Widget noMarks() {
  return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(
      MdiIcons.emoticonSadOutline,
      size: 50,
    ),
    Text(
      getTranslatedString("possibleNoMarks"),
      textAlign: TextAlign.center,
    )
  ]));
}
