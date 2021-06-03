import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/calculator.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/getAllSubjectsAv.dart';
import 'package:novynaplo/ui/screens/calculator/whatIf_module.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'calculator_module.dart';

//TODO: Add option to add mark calculator marks to what if
//TODO: add performance to mark calculator and also make averages a before and after gauge pair
List<String> dropdownValues = [];
String dropdownValue = dropdownValues[0];
List<CalculatorData> averageList = [];
int currentIndex = 0;
TabController _tabController;

num currCount = 0;
num currSum = 0;

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
    }
    getAllSubjectsAv(stats.allParsedSubjects);
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
      drawer: GlobalDrawer.getDrawer(CalculatorTab.tag, context),
      appBar: AppBar(
        title: Text(CalculatorTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: calcTabs,
        ),
      ),
      body: TabBarView(
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

/// Get the easiest way to get to a specific average
/// Parameters:
///
/// ```dart
/// getEasiest(jegyekÖsszege,jegyekSzáma,mennyiJegyAlattt,elAkarÉrni)
/// ```
String getEasiest(num jegyek, jsz, th, elak) {
  bool isInteger(num value) => value is int || value == value.roundToDouble();
  //jegyek = "jegyeid összege"
  //jsz = "jegyeid száma"
  //th = "mennyi jegy alatt akarod elérni?"
  //elak = "milyen átlagot akarsz elérni?"

  if (jsz == 0 || jegyek == 0) {
    if (isInteger(elak)) {
      return "1 ${getTranslatedString("count")} $elak";
    }
  }

  var atlag = jegyek / jsz; //átlag
  var x = elak * jsz +
      elak * th -
      jegyek; //mennyi jegyet kell hozzáadni, hogy elérjük az adott átlagot

  var j2 = th *
      5; // rontásnál mennyi jegyet kell hozzáadni, hogy elérjük az adottátlagot
  var j1 = jegyek + j2 / jsz + th; // az átlag amit a rontásnál számolunk

  if (!isInteger(x)) {
    x = x.round();
  }

  while (j1 > elak) {
    j2 = j2 - 1;
    j1 = (jegyek + j2) / (th + jsz);
  }

  if (!isInteger(j1)) {
    j1 = j1.round();
  }

  var t = th;
  var n = 0;
  num c = x / th;
  num cc = j2 / th;

  int ww = cc.toInt();
  int w = c.toInt();
  if (elak >= atlag) {
    if (x - 5 * th > 0) {
      return getTranslatedString("notPos");
    } else {
      switch (w) {
        case 1:
          while (t + n * 2 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("twos")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("ones")}";
          break;
        case 2:
          while (t * 2 + n * 3 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("threes")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("twos")}";
          break;
        case 3:
          while (t * 3 + n * 4 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("threes")}";
          break;
        case 4:
          while (t * 4 + n * 5 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$t ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $n ${getTranslatedString("count")} ${getTranslatedString("fives")}";
          break;
        case 5:
          return "$th ${getTranslatedString("count")} ${getTranslatedString("fives")}";
          break;
        default:
          return getTranslatedString("notPos");
          break;
      }
    }
  } else {
    if (j2 - th < 0) {
      return getTranslatedString("notPos");
    } else {
      switch (ww) {
        case 1:
          while (t + n * 2 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("twos")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("ones")}";
          break;
        case 2:
          while (t * 2 + n * 3 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("threes")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("twos")}";
          break;
        case 3:
          while (t * 3 + n * 4 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("threes")}";
          break;
        case 4:
          while (t * 4 + n * 5 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$t ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $n ${getTranslatedString("count")} ${getTranslatedString("fives")}";
          break;
        default:
          return getTranslatedString("notPos");
          break;
      }
    }
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
