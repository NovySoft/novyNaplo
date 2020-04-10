import 'package:dynamic_theme/dynamic_theme.dart';
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

var allParsedSubjects = [];
var colors;
final List<Tab> statTabs = <Tab>[
  Tab(text: 'Általános', icon: Icon(MdiIcons.chartScatterPlotHexbin)),
  Tab(text: 'Tantárgy szerinti', icon: Icon(Icons.view_list)),
];
TabController _tabController;
List<charts.Series<LinearMarkChartData, int>> allSubjectsChartData;
AV globalAllSubjectAv = new AV();
AV worstSubjectAv = new AV();
AV bestSubjectAv = new AV();
List<charts.Series> pieList;
List<charts.Series<dynamic, String>> howManyFromMarks;
double sizedBoxHeight = 75;
//Classes used by charts
class AV {
  double value;
  double diffSinceLast;
  String subject = "";
  int count = 0;
}

class LinearPiData {
  final int id;
  final int value;
  final String name;

  LinearPiData(this.id, this.value, this.name);
}

class MarkForBars {
  final String name;
  int count;

  MarkForBars(this.name, this.count);
}

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
            if (globals.markCount == 0) return noMarks();
            if (allParsedSubjects.length > 15){
              sizedBoxHeight = ((allParsedSubjects.length - 15) * 23).toDouble(); 
            }else{
              sizedBoxHeight = 0;
            }
            if (tab.text.toLowerCase() == "általános") {
              Color avColor, worstAvColor, bestAvColor;
              Icon avIcon, worstAvIcon, bestAvIcon;
              setState(() {
                getAllSubjectsAv(allParsedSubjects);
                getWorstAndBest(allParsedSubjects);
                getPieChart(allParsedSubjects);
                getBarChart(allParsedSubjects);
                if (globalAllSubjectAv.diffSinceLast == 0) {
                  avColor = Colors.orange;
                  avIcon = Icon(
                    Icons.linear_scale,
                    color: avColor,
                  );
                } else if (globalAllSubjectAv.diffSinceLast < 0) {
                  avColor = Colors.red;
                  avIcon = Icon(Icons.keyboard_arrow_down, color: avColor);
                } else if (globalAllSubjectAv.diffSinceLast > 0) {
                  avColor = Colors.green;
                  avIcon = Icon(Icons.keyboard_arrow_up, color: avColor);
                }
                if (worstSubjectAv.diffSinceLast == 0) {
                  worstAvColor = Colors.orange;
                  worstAvIcon = Icon(
                    Icons.linear_scale,
                    color: worstAvColor,
                  );
                } else if (worstSubjectAv.diffSinceLast < 0) {
                  worstAvColor = Colors.red;
                  worstAvIcon =
                      Icon(Icons.keyboard_arrow_down, color: worstAvColor);
                } else if (worstSubjectAv.diffSinceLast > 0) {
                  worstAvColor = Colors.green;
                  worstAvIcon =
                      Icon(Icons.keyboard_arrow_up, color: worstAvColor);
                }
                if (bestSubjectAv.diffSinceLast == 0) {
                  bestAvColor = Colors.orange;
                  bestAvIcon = Icon(
                    Icons.linear_scale,
                    color: bestAvColor,
                  );
                } else if (bestSubjectAv.diffSinceLast < 0) {
                  bestAvColor = Colors.red;
                  bestAvIcon =
                      Icon(Icons.keyboard_arrow_down, color: bestAvColor);
                } else if (bestSubjectAv.diffSinceLast > 0) {
                  bestAvColor = Colors.green;
                  bestAvIcon =
                      Icon(Icons.keyboard_arrow_up, color: bestAvColor);
                }
              });
              final axis = charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                fontSize: 15,
                color: charts.MaterialPalette.blue.shadeDefault,
              )));

              final axisTwo = charts.NumericAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    fontSize: 15,
                    color: charts.MaterialPalette.blue.shadeDefault),
              ));
              return ListView.builder(
                itemCount: 11 + globals.adModifier,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                      if (globals.statChart == "Mindent") {
                        return SizedBox(
                          height: 500 + sizedBoxHeight,
                          child: charts.NumericComboChart(
                            createAllSubjectChartData(allParsedSubjects),
                            animate: globals.chartAnimations,
                            domainAxis: axisTwo,
                            primaryMeasureAxis: axis,
                            // Configure the default renderer as a line renderer. This will be used
                            // for any series that does not define a rendererIdKey.
                            defaultRenderer: new charts.LineRendererConfig(
                                includePoints: true),
                            behaviors: [
                              new charts.SeriesLegend(
                                position: charts.BehaviorPosition.end,
                              ),
                              new charts.PanAndZoomBehavior()
                            ],
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: 400,
                          child: charts.LineChart(
                            createOsszesitett(allParsedSubjects),
                            animate: globals.chartAnimations,
                            domainAxis: axisTwo,
                            primaryMeasureAxis: axis,
                            // Configure the default renderer as a line renderer. This will be used
                            // for any series that does not define a rendererIdKey.
                            defaultRenderer: new charts.LineRendererConfig(
                                includePoints: true),
                            behaviors: [new charts.PanAndZoomBehavior()],
                          ),
                        );
                      }
                      break;
                    case 1:
                      return SizedBox(
                        height: 75,
                      );
                      break;
                    case 2:
                      return Row(
                        children: <Widget>[
                          Text(
                            "Összesített átlag: " +
                                globalAllSubjectAv.value.toStringAsFixed(3),
                            textAlign: TextAlign.start,
                            style: new TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          avIcon,
                          Text(
                            globalAllSubjectAv.diffSinceLast.toStringAsFixed(3),
                            style: TextStyle(color: avColor),
                          )
                        ],
                      );
                      break;
                    case 3:
                      return Row(
                        children: <Widget>[
                          Text(
                            "Legroszabb (" + worstSubjectAv.subject + ")",
                            textAlign: TextAlign.start,
                            style: new TextStyle(color: Colors.red),
                          ),
                          Text(
                            " átlag: " +
                                worstSubjectAv.value.toStringAsFixed(3),
                            textAlign: TextAlign.start,
                          ),
                          worstAvIcon,
                          Text(
                            worstSubjectAv.diffSinceLast.toStringAsFixed(3),
                            style: TextStyle(color: worstAvColor),
                          )
                        ],
                      );
                      break;
                    case 4:
                      return Row(
                        children: <Widget>[
                          Text(
                            "Legjobb (" + bestSubjectAv.subject + ")",
                            textAlign: TextAlign.start,
                            style: new TextStyle(color: Colors.green),
                          ),
                          Text(
                            " átlag: " + bestSubjectAv.value.toStringAsFixed(3),
                            textAlign: TextAlign.start,
                          ),
                          bestAvIcon,
                          Text(
                            bestSubjectAv.diffSinceLast.toStringAsFixed(3),
                            style: TextStyle(color: bestAvColor),
                          ),
                        ],
                      );
                      break;
                    case 5:
                      return SizedBox(
                        height: 25,
                      );
                      break;
                    case 6:
                      return Center(
                        child: Text(
                          "Jegyek száma bizonyos tantárgyakból:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                      break;
                    case 7:
                      return SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: new charts.PieChart(
                            pieList,
                            animate: globals.chartAnimations,
                            defaultRenderer: new charts.ArcRendererConfig(
                                arcRendererDecorators: [
                                  new charts.ArcLabelDecorator(
                                      labelPosition:
                                          charts.ArcLabelPosition.inside)
                                ]),
                          ));
                      break;
                    case 8:
                      return SizedBox(
                        height: 25,
                      );
                      break;
                    case 9:
                      return Center(
                        child: Text(
                          "Bizonyos jegyek száma:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                      break;
                    case 10:
                      if (DynamicTheme.of(context).brightness ==
                          Brightness.dark) {
                        return SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: charts.BarChart(
                            howManyFromMarks,
                            animate: globals.chartAnimations,
                            domainAxis: new charts.OrdinalAxisSpec(
                                renderSpec: charts.SmallTickRendererSpec(
                                    labelStyle: charts.TextStyleSpec(
                              fontSize: 15,
                              color: charts.MaterialPalette.blue.shadeDefault,
                            ))),
                            primaryMeasureAxis: new charts.NumericAxisSpec(
                                renderSpec: charts.GridlineRendererSpec(
                                    labelStyle: charts.TextStyleSpec(
                              fontSize: 15,
                              color: charts.MaterialPalette.blue.shadeDefault,
                            ))),
                            defaultRenderer: new charts.BarRendererConfig(
                                barRendererDecorator:
                                    new charts.BarLabelDecorator<String>(
                                        insideLabelStyleSpec:
                                            new charts.TextStyleSpec(
                                                color: charts
                                                    .MaterialPalette.white),
                                        outsideLabelStyleSpec:
                                            new charts.TextStyleSpec(
                                                color: charts
                                                    .MaterialPalette.white)),
                                cornerStrategy:
                                    const charts.ConstCornerStrategy(30)),
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: charts.BarChart(
                            howManyFromMarks,
                            animate: globals.chartAnimations,
                            domainAxis: new charts.OrdinalAxisSpec(
                                renderSpec: charts.SmallTickRendererSpec(
                                    labelStyle: charts.TextStyleSpec(
                              fontSize: 15,
                              color: charts.MaterialPalette.blue.shadeDefault,
                            ))),
                            primaryMeasureAxis: new charts.NumericAxisSpec(
                                renderSpec: charts.GridlineRendererSpec(
                                    labelStyle: charts.TextStyleSpec(
                              fontSize: 15,
                              color: charts.MaterialPalette.blue.shadeDefault,
                            ))),
                            defaultRenderer: new charts.BarRendererConfig(
                                barRendererDecorator:
                                    new charts.BarLabelDecorator<String>(
                                        insideLabelStyleSpec:
                                            new charts.TextStyleSpec(
                                                color: charts
                                                    .MaterialPalette.white),
                                        outsideLabelStyleSpec:
                                            new charts.TextStyleSpec(
                                                color: charts
                                                    .MaterialPalette.black)),
                                cornerStrategy:
                                    const charts.ConstCornerStrategy(30)),
                          ),
                        );
                      }
                      break;
                    default:
                      return SizedBox(
                        height: 150,
                      );
                      break;
                  }
                },
              );
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

  Widget noMarks() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonSadOutline,
        size: 50,
      ),
      Text(
        "Nincs még jegyed!\nNem tudunk statisztikát mutatni",
        textAlign: TextAlign.center,
      )
    ]));
  }

  Widget _chartsListBuilder(BuildContext context, int index) {
    if (index >= allParsedSubjects.length) {
      return SizedBox(height: 100);
    }
    Color currColor = colors[index];
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedChartsCard(
          title: capitalize(allParsedSubjects[index][0].subject),
          color: currColor,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: ChartsDetailTab(
            id: index,
            subject: capitalize(allParsedSubjects[index][0].subject),
            color: currColor,
            seriesList:
                createSubjectChart(allParsedSubjects[index], index.toString()),
            animate: globals.chartAnimations,
          ),
        ));
  }
}
