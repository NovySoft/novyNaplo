import 'package:charts_flutter/flutter.dart' as charts;
import 'package:customgauge/customgauge.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/charts/createOsszesitett.dart';
import 'package:novynaplo/helpers/charts/createSubjectChart.dart';
import 'package:novynaplo/helpers/logicAndMath/calcPercentFromEvalsList.dart';
import 'package:novynaplo/helpers/logicAndMath/getSameSubjectEvals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/textColor/drawerText.dart';

// TODO: Fix landscape UI
class ChartsDetailTab extends StatelessWidget {
  ChartsDetailTab({
    this.subject,
    this.color,
    this.id,
    this.inputList,
    this.animate,
  });

  final int id;
  final String subject;
  final Color color;
  final List<Evals> inputList;
  final bool animate;

  final axis = charts.NumericAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
    fontSize: 10,
    color: charts.MaterialPalette.blue.shadeDefault,
  )));

  final axisTwo = charts.NumericAxisSpec(
      renderSpec: charts.SmallTickRendererSpec(
    labelStyle: charts.TextStyleSpec(
        fontSize: 10, color: charts.MaterialPalette.blue.shadeDefault),
  ));

  @override
  Widget build(BuildContext context) {
    List<charts.Series<LinearMarkChartData, int>> seriesList = [];
    double halfYearMarker;
    if (inputList.length > 0) {
      if (inputList[0].subject.name == "-contracted-") {
        seriesList = createOsszesitett(stats.allParsedSubjectsWithoutZeros);
      } else {
        ChartReturn data = createSubjectChart(
          inputList,
          inputList[0].subject.fullName,
          DynamicTheme.of(context).themeMode == ThemeMode.light,
        );
        seriesList = data.points;
        halfYearMarker = data.halfYearMarker;
      }
    }
    FirebaseCrashlytics.instance.log("Shown Charts_detail_tab");
    Color textCol;
    if (seriesList.last.data.last.value >= 4) {
      textCol = Colors.green;
    } else if (seriesList.last.data.last.value >= 3) {
      textCol = Colors.orange;
    } else if (seriesList.last.data.last.value >= 3) {
      textCol = Colors.red[400];
    } else {
      textCol = Colors.red[900];
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor: getDrawerForeground(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                  child: Center(
                    child: Text(
                      subject,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        color: globals.statisticsCardTheme == "Dark" ||
                                (globals.darker &&
                                    inputList[0].subject.name == "-contracted-")
                            ? Colors.grey[350]
                            : Colors.black,
                      ),
                    ),
                  )),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                      if (globals.currentUser.institution.customizationOptions
                              .canViewClassAV &&
                          inputList[0].subject.name != "-contracted-") {
                        double classAvOfSubject =
                            stats.classAverages[inputList[0].subject.uid] ?? 0;
                        Color classAvColor = Colors.red;
                        if (classAvOfSubject < 2.5) {
                          classAvColor = (Colors.redAccent[700]);
                        } else if (classAvOfSubject < 3 &&
                            classAvOfSubject >= 2.5) {
                          classAvColor = (Colors.redAccent);
                        } else if (classAvOfSubject < 4 &&
                            classAvOfSubject >= 3) {
                          classAvColor = (Colors.yellow[800]);
                        } else if (classAvOfSubject >= 4) {
                          classAvColor = (Colors.green);
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              getTranslatedString("performance"),
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Wrap(
                              children: <Widget>[
                                CustomGauge(
                                  needleColor: globals.darker
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                  gaugeSize: 200,
                                  minValue: 1,
                                  maxValue: 5,
                                  segments: [
                                    GaugeSegment('1', 1, Colors.red[900]),
                                    GaugeSegment('1', 1, Colors.red[400]),
                                    GaugeSegment('2', 1, Colors.orange),
                                    GaugeSegment('4', 1, Colors.green),
                                  ],
                                  currentValue: seriesList.last.data.last.value,
                                  displayWidget: Text(
                                    '${capitalize(getTranslatedString("av"))}:',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  valueWidget: Text(
                                    seriesList.last.data.last.value
                                        .toStringAsFixed(3),
                                    style:
                                        TextStyle(fontSize: 21, color: textCol),
                                  ),
                                  endMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  startMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                CustomGauge(
                                  needleColor: globals.darker
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                  gaugeSize: 200,
                                  minValue: 1,
                                  maxValue: 5,
                                  segments: [
                                    GaugeSegment('1', 1, Colors.red[900]),
                                    GaugeSegment('2', 1, Colors.red[400]),
                                    GaugeSegment('3', 1, Colors.orange),
                                    GaugeSegment('4', 1, Colors.green),
                                  ],
                                  currentValue: classAvOfSubject,
                                  displayWidget: Text(
                                    getTranslatedString("classAvS") + ":",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  valueWidget: Text(
                                    classAvOfSubject.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 21,
                                      color: classAvColor,
                                    ),
                                  ),
                                  endMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  startMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        int performancePercentage = calcPercentFromEvalsList(
                          av: seriesList.last.data.last.value,
                          evalList: getSameSubjectEvals(
                            subject: subject,
                            sort: true,
                          ),
                        );
                        Color textColPercent;
                        if (performancePercentage >= 75) {
                          textColPercent = Colors.green;
                        } else if (performancePercentage >= 50) {
                          textColPercent = Colors.orange;
                        } else if (performancePercentage >= 25) {
                          textColPercent = Colors.red[400];
                        } else {
                          textColPercent = Colors.red[900];
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              getTranslatedString("performance"),
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Wrap(
                              children: <Widget>[
                                CustomGauge(
                                  needleColor: globals.darker
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                  gaugeSize: 200,
                                  minValue: 1,
                                  maxValue: 5,
                                  segments: [
                                    GaugeSegment('1', 1, Colors.red[900]),
                                    GaugeSegment('1', 1, Colors.red[400]),
                                    GaugeSegment('2', 1, Colors.orange),
                                    GaugeSegment('4', 1, Colors.green),
                                  ],
                                  currentValue: seriesList.last.data.last.value,
                                  displayWidget: Text(
                                    '${capitalize(getTranslatedString("av"))}:',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  valueWidget: Text(
                                    seriesList.last.data.last.value
                                        .toStringAsFixed(3),
                                    style:
                                        TextStyle(fontSize: 21, color: textCol),
                                  ),
                                  endMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  startMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                CustomGauge(
                                  needleColor: globals.darker
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                  gaugeSize: 200,
                                  minValue: 0,
                                  maxValue: 100,
                                  segments: [
                                    GaugeSegment('1', 25, Colors.red[900]),
                                    GaugeSegment('2', 25, Colors.red[400]),
                                    GaugeSegment('3', 25, Colors.orange),
                                    GaugeSegment('4', 25, Colors.green),
                                  ],
                                  currentValue:
                                      performancePercentage.toDouble(),
                                  displayWidget: Text(
                                    '${capitalize(getTranslatedString("inPc"))}:',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  valueWidget: Text(
                                    performancePercentage.toString() + "%",
                                    style: TextStyle(
                                      fontSize: 21,
                                      color: textColPercent,
                                    ),
                                  ),
                                  endMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  startMarkerStyle: TextStyle(
                                    fontSize: 10,
                                    color: DynamicTheme.of(context).themeMode ==
                                            ThemeMode.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      break;
                    case 1:
                      return Row(
                        children: [
                          SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 500,
                              child: new charts.LineChart(
                                seriesList,
                                behaviors: [
                                  new charts.PanAndZoomBehavior(),
                                  if (halfYearMarker != null)
                                    new charts.RangeAnnotation([
                                      new charts.LineAnnotationSegment(
                                          halfYearMarker,
                                          charts.RangeAnnotationAxisType.domain,
                                          startLabel: "   " +
                                              getTranslatedString(
                                                "HalfYearChart",
                                              ),
                                          labelPosition: charts
                                              .AnnotationLabelPosition.margin,
                                          labelAnchor: charts
                                              .AnnotationLabelAnchor.start,
                                          color: DynamicTheme.of(context)
                                                      .themeMode ==
                                                  ThemeMode.dark
                                              ? charts.Color.white
                                              : charts.Color.fromHex(
                                                  code: "#000000",
                                                ),
                                          labelStyleSpec: charts.TextStyleSpec(
                                            fontSize: 18,
                                            color: DynamicTheme.of(context)
                                                        .themeMode ==
                                                    ThemeMode.dark
                                                ? charts.Color.white
                                                : charts.Color.black,
                                          )),
                                    ]),
                                ],
                                animate: animate,
                                domainAxis: axisTwo,
                                primaryMeasureAxis: axis,
                                defaultRenderer: new charts.LineRendererConfig(
                                  includePoints: true,
                                ),
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
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
