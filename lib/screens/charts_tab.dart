import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/screens/charts_detail_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/screens/notices_detail_tab.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/screens/calculator_tab.dart';
var allParsedSubjects;
var colors;


class ChartsTab extends StatefulWidget {
  static String tag = 'charts';
  static const title = 'Grafikonok';

  @override
  _ChartsTabState createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ChartsTab.title),
      ),
      drawer: getDrawer(ChartsTab.tag,context),
      body: ListView.builder(
        itemCount: allParsedSubjects.length,
        padding: EdgeInsets.symmetric(vertical: 12),
        itemBuilder: _chartsListBuilder,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

Widget _chartsListBuilder(BuildContext context, int index) {
  MaterialColor currColor = colors[index];
  List<int> currSubjectMarks = [];
  for(var n in allParsedSubjects[index]){
    currSubjectMarks.add(int.parse(n.split(":")[1]));
  }
  return SafeArea(
    top: false,
    bottom: false,
    child: AnimatedChartsCard(
        title: capitalize(allParsedSubjects[index][0].split(":")[0]),
        color: currColor,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => ChartsDetailTab(
              id: index,
              subject: capitalize(allParsedSubjects[index][0].split(":")[0]),
              color: currColor,
              seriesList: createSubjectChart(currSubjectMarks,index.toString()),
              animate: true,
            ),
          ),
        );
      })
  );
}