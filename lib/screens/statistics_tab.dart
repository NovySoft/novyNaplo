import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/screens/charts_detail_tab.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'dart:math';

var allParsedSubjects;
var colors;
final List<Tab> statTabs = <Tab>[
  Tab(text: 'Általános', icon: Icon(MdiIcons.chartScatterPlotHexbin)),
  Tab(text: 'Tantárgy szerinti', icon: Icon(Icons.view_list)),
];
TabController _tabController;
List<charts.Series<LinearMarkChartData, int>> allSubjectsChartData;

class StatisticsTab extends StatefulWidget {
  static String tag = 'statistics';
  static const title = 'Statisztika';

  @override
  _StatisticsTabState createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatisticsTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: statTabs,
        ),
      ),
      drawer: getDrawer(StatisticsTab.tag, context),
      body: TabBarView(
          controller: _tabController,
          children: statTabs.map((Tab tab) {
            if (tab.text.toLowerCase() == "általános") {
              final axis = charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                fontSize: 10,
                color: charts.MaterialPalette.blue.shadeDefault,
              )));

              final axisTwo = charts.NumericAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    fontSize: 10,
                    color: charts.MaterialPalette.blue.shadeDefault),
              ));
              return Column(
                children: [
                  SizedBox(
                    height: 500,
                    child: charts.NumericComboChart(
                      createAllSubjectChartData(allParsedSubjects),
                      animate: false,
                      domainAxis: axisTwo,
                      primaryMeasureAxis: axis,
                      // Configure the default renderer as a line renderer. This will be used
                      // for any series that does not define a rendererIdKey.
                      defaultRenderer:
                          new charts.LineRendererConfig(includePoints: true),
                      behaviors: [
                        new charts.SeriesLegend(
                            position: charts.BehaviorPosition.end),
                        new charts.PanAndZoomBehavior()
                      ],
                    ),
                  )
                ],
              );
              //return Text("alma");
            } else {
              return ListView.builder(
                  itemCount: allParsedSubjects.length + globals.adModifier,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: _chartsListBuilder);
            }
          }).toList()),
    );
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }
}

Widget _chartsListBuilder(BuildContext context, int index) {
  if (index >= allParsedSubjects.length) {
    return SizedBox(height: 100);
  }
  Color currColor = colors[index];
  List<int> currSubjectMarks = [];
  for (var n in allParsedSubjects[index]) {
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
                  subject:
                      capitalize(allParsedSubjects[index][0].split(":")[0]),
                  color: currColor,
                  seriesList:
                      createSubjectChart(currSubjectMarks, index.toString()),
                  animate: true,
                ),
              ),
            );
          }));
}
