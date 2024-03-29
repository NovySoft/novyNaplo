import 'package:animations/animations.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/helpers/charts/absencesCharts.dart';
import 'package:novynaplo/helpers/charts/createAllSubjectChartData.dart';
import 'package:novynaplo/helpers/charts/getBarChart.dart';
import 'package:novynaplo/helpers/charts/getPieChartOrBarChart.dart';
import 'package:novynaplo/helpers/logicAndMath/getAllSubjectsAv.dart';
import 'package:novynaplo/helpers/logicAndMath/getMarksWithChanges.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/cardColor/statiscticsCard.dart';
import 'package:novynaplo/helpers/ui/modifyColor.dart';
import 'package:novynaplo/ui/screens/absences_tab.dart';
import 'package:novynaplo/ui/screens/charts_detail_tab.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedChartsTitleCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/helpers/ui/textColor/drawerText.dart';

List<List<Evals>> allParsedSubjects = [];
List<List<Evals>> allParsedSubjectsWithoutZeros = [];
Map<String, double> halfYearMarkers = {};
Map<String, double> classAverages = {};
//FIXME: Keepalives, once loaded

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
Average osszesitettAv = new Average();
List<charts.Series> pieList;
List<charts.Series<dynamic, String>> howManyFromMarks;
List<charts.Series<dynamic, String>> howManyFromSpecific;
double sizedBoxHeight = 75;
List<Average> allSubjectsAv = [];

class StatisticsTab extends StatefulWidget {
  StatisticsTab({
    this.startOnSubjects = false,
  });

  static String tag = 'statistics';
  static String title = getTranslatedString("statistics");
  final bool startOnSubjects;

  @override
  _StatisticsTabState createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab>
    with TickerProviderStateMixin {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Statistics");
    getAllSubjectsAv(allParsedSubjectsWithoutZeros);
    getMarksWithChanges(
      allParsedSubjectsWithoutZeros,
      globals.currentUser,
    );
    getPieChartOrBarChart(allParsedSubjects);
    getBarChart(allParsedSubjects);
    _tabController = new TabController(
      vsync: this,
      length: 2,
      initialIndex: widget.startOnSubjects ? 1 : 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor: getDrawerForeground(),
        title: Text(StatisticsTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: statTabs,
          labelColor: getTabForeground(),
        ),
      ),
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: CustomDrawer(StatisticsTab.tag),
      body: TabBarView(
          controller: _tabController,
          children: statTabs.map((Tab tab) {
            if (allParsedSubjects.length == 0 ||
                marks.allParsedByDate.length == 0) return noMarks();
            if (allParsedSubjects.length > 15) {
              sizedBoxHeight =
                  ((allParsedSubjects.length - 15) * 23).toDouble();
            } else {
              sizedBoxHeight = 0;
            }
            if (tab.text == getTranslatedString("general")) {
              Color avColor;
              Icon avIcon;
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
                itemCount: 11,
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
                            openColor: globals.darker
                                ? Colors.black
                                : DynamicTheme.of(context).themeMode ==
                                        ThemeMode.light
                                    ? Colors.white
                                    : Color.fromARGB(100, 48, 48, 48),
                            closedColor: globals.darker
                                ? Colors.black
                                : DynamicTheme.of(context).themeMode ==
                                        ThemeMode.light
                                    ? Colors.white
                                    : Color.fromARGB(100, 48, 48, 48),
                            transitionDuration: Duration(milliseconds: 550),
                            openBuilder: (_, __) => AbsencesTab(),
                            closedBuilder: (_, callback) => Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: SizedBox(
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
                            ),
                          ),
                        ],
                      );
                      break;
                    case 1:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          Center(
                            child: Text(
                              "${getTranslatedString("marksAndAvs")}:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
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
                                    defaultRenderer:
                                        new charts.LineRendererConfig(
                                            includePoints: true),
                                    behaviors: [
                                      new charts.SeriesLegend(
                                        position: charts.BehaviorPosition.end,
                                      ),
                                      new charts.PanAndZoomBehavior()
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                              SizedBox(
                                width: 10,
                              ),
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
                                style: TextStyle(
                                  color: lighten(avColor, 20),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8, width: 15),
                        ],
                      );
                      break;
                    case 4:
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                Color diffColor;
                                Widget diffIcon;
                                Average currentAv = allSubjectsAv[index];
                                if (currentAv.diffSinceLast == 0) {
                                  diffColor = Colors.orange;
                                  diffIcon = Icon(
                                    Icons.linear_scale,
                                    color: diffColor,
                                  );
                                } else if (currentAv.diffSinceLast < 0) {
                                  diffColor = Colors.red;
                                  diffIcon = Icon(
                                    Icons.keyboard_arrow_down,
                                    color: diffColor,
                                  );
                                } else if (currentAv.diffSinceLast > 0) {
                                  diffColor = Colors.green;
                                  diffIcon = Icon(
                                    Icons.keyboard_arrow_up,
                                    color: diffColor,
                                  );
                                }
                                Color avgColor =
                                    DynamicTheme.of(context).themeMode ==
                                            ThemeMode.dark
                                        ? Colors.white
                                        : Colors.black;
                                if (globals.colorAvsInStatisctics) {
                                  if (currentAv.value == null) {
                                    avgColor = (Colors.red);
                                  } else if (currentAv.value < 2.5) {
                                    avgColor = (Colors.redAccent[700]);
                                  } else if (currentAv.value < 3 &&
                                      currentAv.value >= 2.5) {
                                    avgColor = (Colors.redAccent);
                                  } else if (currentAv.value < 4 &&
                                      currentAv.value >= 3) {
                                    avgColor = (Colors.yellow[800]);
                                  } else {
                                    avgColor = (Colors.green);
                                  }
                                }
                                return Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      capitalize(currentAv.subjectName) + ": ",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: avgColor,
                                      ),
                                    ),
                                    Text(
                                      currentAv.value.toStringAsFixed(3),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    diffIcon,
                                    Text(
                                      currentAv.diffSinceLast
                                          .toStringAsFixed(3),
                                      style: TextStyle(
                                        color: lighten(diffColor, 20),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) => SizedBox(
                                height: 8,
                              ),
                              itemCount: allSubjectsAv.length,
                            ),
                          )
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
                          globals.howManyGraph == "Kör diagram"
                              ? "${getTranslatedString("marksFromSubjects")}:"
                              : "${getTranslatedString("marksDistribution")}:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                      break;
                    case 7:
                      if (globals.howManyGraph == "Kör diagram") {
                        return SizedBox(
                            height: 400,
                            width: double.infinity,
                            child: new charts.PieChart(
                              pieList,
                              animate: globals.chartAnimations,
                              defaultRenderer: new charts
                                  .ArcRendererConfig(arcRendererDecorators: [
                                new charts.ArcLabelDecorator(
                                  labelPosition: charts.ArcLabelPosition.auto,
                                  outsideLabelStyleSpec: charts.TextStyleSpec(
                                    fontSize: 12,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.dark
                                        ? charts.Color.white
                                        : charts.Color.black,
                                  ),
                                )
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
                    case 8:
                      return SizedBox(
                        height: 25,
                      );
                      break;
                    case 9:
                      return Center(
                        child: Text(
                          "${getTranslatedString("countOfSpecMarks")}:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                      break;
                    case 10:
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 400,
                              width: double.infinity,
                              child: charts.BarChart(
                                howManyFromMarks,
                                animate: globals.chartAnimations,
                                domainAxis: new charts.OrdinalAxisSpec(
                                    renderSpec: charts.SmallTickRendererSpec(
                                        labelStyle: charts.TextStyleSpec(
                                  fontSize: 15,
                                  color:
                                      charts.MaterialPalette.blue.shadeDefault,
                                ))),
                                primaryMeasureAxis: new charts.NumericAxisSpec(
                                    renderSpec: charts.GridlineRendererSpec(
                                        labelStyle: charts.TextStyleSpec(
                                  fontSize: 15,
                                  color:
                                      charts.MaterialPalette.blue.shadeDefault,
                                ))),
                                defaultRenderer: new charts.BarRendererConfig(
                                    barRendererDecorator:
                                        new charts.BarLabelDecorator<String>(
                                            insideLabelStyleSpec:
                                                new charts.TextStyleSpec(
                                                    color: charts.MaterialPalette
                                                        .white),
                                            outsideLabelStyleSpec:
                                                new charts.TextStyleSpec(
                                                    color:
                                                        DynamicTheme.of(context)
                                                                    .themeMode ==
                                                                ThemeMode.dark
                                                            ? charts
                                                                .MaterialPalette
                                                                .white
                                                            : charts
                                                                .MaterialPalette
                                                                .black)),
                                    cornerStrategy:
                                        const charts.ConstCornerStrategy(30)),
                              ),
                            ),
                          ),
                        ],
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
                      1, //+1 due to összesített
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: _chartsListBuilder);
            }
          }).toList()),
    );
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
    Color currColor = getStatiscticsCardColor(
      index,
      context: context,
      eval: index == 0
          ? Evals(
              subject: Subject(fullName: "-contracted-"),
            )
          : allParsedSubjectsWithoutZeros[index - 1][0],
    );
    if (index == 0) {
      return SafeArea(
        child: AnimatedChartsTitleCard(
          eval: Evals(
            subject: Subject(fullName: "-contracted-"),
          ),
          title: capitalize(getTranslatedString("contracted")),
          color: currColor,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: ChartsDetailTab(
            id: index,
            subject: capitalize(getTranslatedString("contracted")),
            color: currColor,
            inputList: [Evals(subject: Subject(name: "-contracted-"))],
            animate: globals.chartAnimations,
          ),
        ),
      );
    }
    int statListIndex = allParsedSubjects.indexWhere((element) =>
        element[0].subject.fullName.toLowerCase() ==
        allParsedSubjectsWithoutZeros[index - 1][0]
            .subject
            .fullName
            .toLowerCase());
    List<Evals> chartListPoints = [];
    if (statListIndex != -1) {
      chartListPoints = List.from(allParsedSubjects[statListIndex]);
    } else if (allParsedSubjectsWithoutZeros[index - 1].length > 0) {
      chartListPoints = List.from(allParsedSubjectsWithoutZeros[index - 1]);
    }
    return SafeArea(
      child: AnimatedChartsTitleCard(
        eval: allParsedSubjectsWithoutZeros[index - 1][0],
        title: capitalize(
            allParsedSubjectsWithoutZeros[index - 1][0].subject.name),
        color: currColor,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: ChartsDetailTab(
          id: index,
          subject: capitalize(
              allParsedSubjectsWithoutZeros[index - 1][0].subject.fullName),
          color: currColor,
          inputList: chartListPoints,
          animate: globals.chartAnimations,
        ),
      ),
    );
  }
}
