import 'package:animations/animations.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/avarage.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/ui/screens/absences_tab.dart';
import 'package:novynaplo/ui/screens/charts_detail_tab.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'package:novynaplo/translations/translationProvider.dart';

var allParsedSubjects = [];
List<List<Evals>> allParsedSubjectsWithoutZeros = [];
//TODO Make subject color constant

final List<Tab> statTabs = <Tab>[
  Tab(
    text: getTranslatedString("general"),
    icon: Icon(MdiIcons.chartScatterPlotHexbin),
  ),
  Tab(
    text: getTranslatedString("bySubject"),
    icon: Icon(Icons.view_list),
  ),
];
TabController _tabController;
List<charts.Series<LinearMarkChartData, int>> allSubjectsChartData;
AV osszesitettAv = new AV();
AV worstSubjectAv = new AV();
AV bestSubjectAv = new AV();
List<charts.Series> pieList;
List<charts.Series<dynamic, String>> howManyFromMarks;
List<charts.Series<dynamic, String>> howManyFromSpecific;
double sizedBoxHeight = 75;
List<AV> allSubjectsAv = [];

//Classes used by charts
class AV {
  double value;
  double diffSinceLast;
  String subject = "";
  double count = 0;

  @override
  String toString() {
    return subject + ":" + value.toStringAsFixed(3);
  }

  Avarage toDatabaseAvarage() {
    Avarage temp = new Avarage();
    temp.ownValue = value;
    temp.subject = subject;
    return temp;
  }
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
  static String title = getTranslatedString("statistics");

  @override
  _StatisticsTabState createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
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
            if (allParsedSubjects.length == 0 ||
                marksPage.allParsedByDate.length == 0) return noMarks();
            if (allParsedSubjects.length > 15) {
              sizedBoxHeight =
                  ((allParsedSubjects.length - 15) * 23).toDouble();
            } else {
              sizedBoxHeight = 0;
            }
            if (tab.text == getTranslatedString("general")) {
              Color avColor, worstAvColor, bestAvColor;
              Icon avIcon, worstAvIcon, bestAvIcon;
              setState(() {
                if (osszesitettAv.diffSinceLast == 0) {
                  avColor = Colors.orange;
                  avIcon = Icon(
                    Icons.linear_scale,
                    color: avColor,
                  );
                } else if (osszesitettAv.diffSinceLast < 0) {
                  avColor = Colors.red;
                  avIcon = Icon(Icons.keyboard_arrow_down, color: avColor);
                } else if (osszesitettAv.diffSinceLast > 0) {
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
                itemCount: 12 + globals.adModifier,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  List<String> hiddenSeries = [];
                  if (!legendSelection.igazolando) {
                    hiddenSeries.add(getTranslatedString("BeJustified"));
                  }
                  if (!legendSelection.igazolatlan) {
                    hiddenSeries.add(getTranslatedString("UnJustified"));
                  }
                  if (!legendSelection.igazolt) {
                    hiddenSeries.add(getTranslatedString("Justified"));
                  }
                  switch (index) {
                    case 0:
                      return Column(
                        children: [
                          Center(
                            child: Text(
                              "${getTranslatedString("absencesAndDelays")}:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              "${getTranslatedString("absenceAndDelayInfo")}:",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          OpenContainer(
                            tappable: false,
                            closedElevation: 0,
                            openElevation: 0,
                            openColor: DynamicTheme.of(context).brightness ==
                                    Brightness.light
                                ? Colors.white
                                : Color.fromARGB(100, 48, 48, 48),
                            closedColor: DynamicTheme.of(context).brightness ==
                                    Brightness.light
                                ? Colors.white
                                : Color.fromARGB(100, 48, 48, 48),
                            transitionDuration: Duration(milliseconds: 550),
                            openBuilder: (_, __) => AbsencesTab(),
                            closedBuilder: (_, callback) => SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: AbsencesBarChart(
                                reDraw: true,
                                callback: callback,
                                defaultHiddenSeries: hiddenSeries,
                              ),
                            ),
                          ),
                        ],
                      );
                      break;
                    case 1:
                      return Column(
                        children: [
                          SizedBox(height: 15),
                          Center(
                            child: Text(
                              "${getTranslatedString("marksAndAvs")}:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 500 +
                                sizedBoxHeight +
                                globals.extraSpaceUnderStat,
                            child: charts.NumericComboChart(
                              createAllSubjectChartData(
                                  allParsedSubjectsWithoutZeros),
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
                          ),
                        ],
                      );
                      break;
                    case 2:
                      return SizedBox(
                        height: 75,
                      );
                      break;
                    case 3:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                "${getTranslatedString("combinedAv")}: " +
                                    osszesitettAv.value.toStringAsFixed(3),
                                textAlign: TextAlign.start,
                                style: new TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              avIcon,
                              Text(
                                osszesitettAv.diffSinceLast.toStringAsFixed(3),
                                style: TextStyle(color: avColor, fontSize: 18),
                              ),
                            ],
                          ),
                          SizedBox(height: 8, width: 15),
                        ],
                      );
                      break;
                    case 4:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                "${getTranslatedString("best")} (" +
                                    capitalize(bestSubjectAv.subject) +
                                    ") ${getTranslatedString("av")}: ",
                                textAlign: TextAlign.start,
                                style: new TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                bestSubjectAv.value.toStringAsFixed(3),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              bestAvIcon,
                              Text(
                                bestSubjectAv.diffSinceLast.toStringAsFixed(3),
                                style:
                                    TextStyle(color: bestAvColor, fontSize: 18),
                              ),
                            ],
                          ),
                          SizedBox(height: 8, width: 15),
                        ],
                      );
                      break;
                    case 5:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.separated(
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 8, width: 15),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: allSubjectsAv.length,
                            itemBuilder: (BuildContext context, int index) {
                              Color diffColor;
                              Widget diffIcon;
                              if (allSubjectsAv[index].diffSinceLast == 0) {
                                diffColor = Colors.orange;
                                diffIcon = Icon(
                                  Icons.linear_scale,
                                  color: diffColor,
                                );
                              } else if (allSubjectsAv[index].diffSinceLast <
                                  0) {
                                diffColor = Colors.red;
                                diffIcon = Icon(
                                  Icons.keyboard_arrow_down,
                                  color: diffColor,
                                );
                              } else if (allSubjectsAv[index].diffSinceLast >
                                  0) {
                                diffColor = Colors.green;
                                diffIcon = Icon(
                                  Icons.keyboard_arrow_up,
                                  color: diffColor,
                                );
                              }
                              Color avgColor =
                                  DynamicTheme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black;
                              if (globals.colorAvsInStatisctics) {
                                if (allSubjectsAv[index].value == null) {
                                  avgColor = (Colors.red);
                                } else if (allSubjectsAv[index].value < 2.5) {
                                  avgColor = (Colors.redAccent[700]);
                                } else if (allSubjectsAv[index].value < 3 &&
                                    allSubjectsAv[index].value >= 2.5) {
                                  avgColor = (Colors.redAccent);
                                } else if (allSubjectsAv[index].value < 4 &&
                                    allSubjectsAv[index].value >= 3) {
                                  avgColor = (Colors.yellow[800]);
                                } else {
                                  avgColor = (Colors.green);
                                }
                              }
                              return Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Text(
                                    capitalize(allSubjectsAv[index].subject) +
                                        ": ",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18, color: avgColor),
                                  ),
                                  Text(
                                    allSubjectsAv[index]
                                        .value
                                        .toStringAsFixed(3),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  diffIcon,
                                  Text(
                                    allSubjectsAv[index]
                                        .diffSinceLast
                                        .toStringAsFixed(3),
                                    style: TextStyle(
                                        color: diffColor, fontSize: 18),
                                  )
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 8, width: 15),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                "${getTranslatedString("worst")} (" +
                                    capitalize(worstSubjectAv.subject) +
                                    ") ${getTranslatedString("av")}: ",
                                textAlign: TextAlign.start,
                                style: new TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                worstSubjectAv.value.toStringAsFixed(3),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              worstAvIcon,
                              Text(
                                worstSubjectAv.diffSinceLast.toStringAsFixed(3),
                                style: TextStyle(
                                    color: worstAvColor, fontSize: 18),
                              )
                            ],
                          ),
                        ],
                      );
                      break;
                    case 6:
                      return SizedBox(
                        height: 25,
                      );
                      break;
                    case 7:
                      return Center(
                        child: Text(
                          globals.howManyGraph == "Kör diagram"
                              ? "${getTranslatedString("marksFromSubjects")}:"
                              : "${getTranslatedString("marksDistribution")}:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                      break;
                    case 8:
                      //TODO: Fix chart labels
                      if (globals.howManyGraph == "Kör diagram") {
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
                      } else {
                        return SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: charts.BarChart(
                            howManyFromSpecific,
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
                      }
                      break;
                    case 9:
                      return SizedBox(
                        height: 25,
                      );
                      break;
                    case 10:
                      return Center(
                        child: Text(
                          "${getTranslatedString("countOfSpecMarks")}:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                      break;
                    case 11:
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
                              barRendererDecorator: new charts
                                      .BarLabelDecorator<String>(
                                  insideLabelStyleSpec:
                                      new charts.TextStyleSpec(
                                          color: charts.MaterialPalette.white),
                                  outsideLabelStyleSpec:
                                      new charts.TextStyleSpec(
                                          color: DynamicTheme.of(context)
                                                      .brightness ==
                                                  Brightness.dark
                                              ? charts.MaterialPalette.white
                                              : charts.MaterialPalette.black)),
                              cornerStrategy:
                                  const charts.ConstCornerStrategy(30)),
                        ),
                      );
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
                  itemCount: allParsedSubjectsWithoutZeros.length +
                      1 + //+1 due to összesített
                      globals.adModifier,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: _chartsListBuilder);
            }
          }).toList()),
    );
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Statistics");
    getAllSubjectsAv(allParsedSubjectsWithoutZeros);
    getWorstAndBest(allParsedSubjectsWithoutZeros);
    getPieChartOrBarChart(allParsedSubjects);
    getBarChart(allParsedSubjects);
    if (globals.payloadId != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (globals.notifPayload == "absence") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbsencesTab(),
            ),
          );
        } else if (globals.notifPayload == "avarage") {
          int tempIndex = allParsedSubjectsWithoutZeros.indexWhere(
              (element) => element[0].subject == globals.payloadString);
          Color currColor = marksPage.colors[tempIndex + 1];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChartsDetailTab(
                id: tempIndex,
                subject: capitalize(
                    allParsedSubjectsWithoutZeros[tempIndex][0].subject),
                color: currColor,
                seriesList: createSubjectChart(
                    allParsedSubjectsWithoutZeros[tempIndex], index.toString()),
                animate: globals.chartAnimations,
              ),
            ),
          );
          globals.payloadId = -1;
          globals.notifPayload = "";
        }
      });
    }
    _tabController = new TabController(
      vsync: this,
      length: 2,
      initialIndex: globals.notifPayload == "avarage" ? 1 : 0,
    );
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
        getTranslatedString("possibleNoMarks"),
        textAlign: TextAlign.center,
      )
    ]));
  }

  Widget _chartsListBuilder(BuildContext context, int index) {
    if (index >= allParsedSubjectsWithoutZeros.length + 1) {
      return SizedBox(height: 100);
    }
    Color currColor = marksPage.colors[index];
    if (index == 0) {
      return SafeArea(
        child: AnimatedChartsCard(
          title: capitalize(getTranslatedString("contracted")),
          color: currColor,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: ChartsDetailTab(
            id: index,
            subject: capitalize(getTranslatedString("contracted")),
            color: currColor,
            seriesList: createOsszesitett(allParsedSubjectsWithoutZeros),
            animate: globals.chartAnimations,
          ),
        ),
      );
    }
    return SafeArea(
      child: AnimatedChartsCard(
        title: capitalize(allParsedSubjectsWithoutZeros[index - 1][0].subject),
        color: currColor,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: ChartsDetailTab(
          id: index,
          subject:
              capitalize(allParsedSubjectsWithoutZeros[index - 1][0].subject),
          color: currColor,
          seriesList: createSubjectChart(
              allParsedSubjectsWithoutZeros[index - 1], index.toString()),
          animate: globals.chartAnimations,
        ),
      ),
    );
  }
}
