import 'package:customgauge/customgauge.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/charts/createSubjectChart.dart';
import 'package:novynaplo/helpers/logicAndMath/calcPercentFromEvalsList.dart';
import 'package:novynaplo/helpers/logicAndMath/getSameSubjectEvals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/removeHTMLtags.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class ReportsDetailTab extends StatelessWidget {
  ReportsDetailTab({
    @required this.eval,
    @required this.color,
    @required this.title,
    @required this.inputList,
    this.hideMarker = false,
  });

  final Evals eval;
  final Color color;
  final String title;
  final List<Evals> inputList;
  final bool hideMarker;

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
    FirebaseCrashlytics.instance.log("Shown Reports_detail_tab");
    List<LinearMarkChartData> avList = [LinearMarkChartData(0, 0)];
    List<LinearMarkChartData> classAvList;
    List<charts.Series<dynamic, num>> chartList = [];
    double halfYearMarker;
    if (inputList.length > 0) {
      ChartReturn data = createSubjectChart(
        inputList,
        inputList[0].subject.name,
        DynamicTheme.of(context).themeMode == ThemeMode.light,
      );
      chartList = data.points;
      if (!hideMarker) {
        halfYearMarker = data.halfYearMarker;
      }
    }
    List<charts.Series<dynamic, num>> chartPointList = [];
    if (chartList != null) {
      chartPointList = chartList;
      if (chartList.length >= 2 && chartList[1]?.data != null) {
        avList = List.from(chartList[1].data);
      }
      if (chartList.length >= 2 && chartList[0]?.data != null) {
        classAvList = List.from(chartList[0].data);
        if (classAvList != null && classAvList.length == 0) {
          classAvList = null;
        }
      }
    }
    if (avList.length <= 0) {
      avList = [LinearMarkChartData(0, 0)];
    }

    List<LinearMarkChartData> sortableAvList = List.from(avList);
    sortableAvList.sort((a, b) => a.value.compareTo(b.value));
    List<LinearMarkChartData> sortableClassAvList;
    if (classAvList != null) {
      sortableClassAvList = List.from(classAvList);
      sortableClassAvList.sort((a, b) => a.value.compareTo(b.value));
    }
    double bestDiff = (avList.last.value - sortableAvList.last.value).abs();
    double worstDiff = (avList.last.value - sortableAvList.first.value).abs();

    return Scaffold(
      appBar: AppBar(
        title: Text(capitalize(title)),
        backgroundColor:
            globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor:
            globals.appBarTextColoredByUser ? globals.currentUser.color : null,
      ),
      body: ListView.builder(
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return Center(
                child: Text(
                  eval.createDate.toString().split(".")[0],
                  style: TextStyle(fontSize: 20),
                ),
              );
              break;
            case 1:
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            capitalize((eval.theme.toLowerCase() ==
                                            "dicséret" ||
                                        eval.theme.toLowerCase() == "kitűnő"
                                    ? "${getTranslatedString("praiseworthy")} "
                                    : "") +
                                eval.subject.name +
                                " " +
                                (eval.textValue.contains(htmlMatcher)
                                    ? ''
                                    : eval.textValue)),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    eval.textValue.contains(htmlMatcher)
                        ? Center(child: Html(
                            data: eval.textValue,
                            shrinkWrap: true,
                          ))
                        : SizedBox(height: 5),
                  ],
                ),
              );
              break;
            case 2:
              return SizedBox(
                height: 200,
                child: new charts.LineChart(
                  chartPointList,
                  behaviors: [
                    new charts.PanAndZoomBehavior(),
                    if (halfYearMarker != null)
                      new charts.RangeAnnotation([
                        new charts.LineAnnotationSegment(halfYearMarker,
                            charts.RangeAnnotationAxisType.domain,
                            startLabel: "   " +
                                getTranslatedString(
                                  "HalfYearChart",
                                ),
                            labelPosition:
                                charts.AnnotationLabelPosition.margin,
                            labelAnchor: charts.AnnotationLabelAnchor.start,
                            color: DynamicTheme.of(context).themeMode ==
                                    ThemeMode.dark
                                ? charts.Color.white
                                : charts.Color.fromHex(
                                    code: "#000000",
                                  ),
                            labelStyleSpec: charts.TextStyleSpec(
                              fontSize: 18,
                              color: DynamicTheme.of(context).themeMode ==
                                      ThemeMode.dark
                                  ? charts.Color.white
                                  : charts.Color.black,
                            )),
                      ]),
                  ],
                  animate: globals.chartAnimations,
                  domainAxis: axisTwo,
                  primaryMeasureAxis: axis,
                  defaultRenderer:
                      new charts.LineRendererConfig(includePoints: true),
                ),
              );
              break;
            case 3:
              if (worstDiff > bestDiff) {
                // Távolabb van a legrosszabb átlag
                return Center(
                  child: Text(
                    getTranslatedString("arrowWorstMark"),
                  ),
                );
              } else if (bestDiff > worstDiff) {
                // Távolabb van a legjobb átlag
                return Center(
                  child: Text(
                    getTranslatedString("arrowBestMark"),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    getTranslatedString("arrowFirstMark"),
                  ),
                );
              }
              break;
            case 4:
              Color diffColor;
              Widget diffIcon;
              double diffShower = 0;

              if (worstDiff > bestDiff) {
                diffShower = avList.last.value - sortableAvList.first.value;
              } else if (worstDiff < bestDiff) {
                diffShower = avList.last.value - sortableAvList.last.value;
              }

              if (diffShower == 0) {
                diffColor = Colors.orange;
                diffIcon = Icon(
                  Icons.linear_scale,
                  color: diffColor,
                );
              } else if (diffShower < 0) {
                diffColor = Colors.red;
                diffIcon = Icon(
                  Icons.keyboard_arrow_down,
                  color: diffColor,
                );
              } else if (diffShower > 0) {
                diffColor = Colors.green;
                diffIcon = Icon(
                  Icons.keyboard_arrow_up,
                  color: diffColor,
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 15),
                        Text(
                          "${getTranslatedString("worst")} ${getTranslatedString("av")}: " +
                              sortableAvList.first.value.toStringAsFixed(3),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        sortableClassAvList != null
                            ? Text(
                                "${getTranslatedString("worst")} ${getTranslatedString("classAv").toLowerCase()}: " +
                                    sortableClassAvList.first.value
                                        .toStringAsFixed(3),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(width: 0, height: 0),
                        sortableClassAvList != null
                            ? SizedBox(height: 15)
                            : SizedBox(width: 0, height: 0),
                        Text(
                          "${getTranslatedString("best")} ${getTranslatedString("av")}: " +
                              sortableAvList.last.value.toStringAsFixed(3),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        sortableClassAvList != null
                            ? Text(
                                "${getTranslatedString("best")} ${getTranslatedString("classAv").toLowerCase()}: " +
                                    sortableClassAvList.last.value
                                        .toStringAsFixed(3),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(width: 0, height: 0),
                        sortableClassAvList != null
                            ? SizedBox(height: 15)
                            : SizedBox(width: 0, height: 0),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.start,
                          children: <Widget>[
                            Text(
                              "${capitalize(title)} ${getTranslatedString("av")}: " +
                                  avList.last.value.toStringAsFixed(3),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            diffIcon,
                            Text(
                              "${(diffShower).toStringAsFixed(3)}",
                              style: TextStyle(color: diffColor),
                            ),
                          ],
                        ),
                        sortableClassAvList != null
                            ? Text(
                                "${capitalize(title)} ${getTranslatedString("classAv").toLowerCase()}: " +
                                    classAvList.last.value.toStringAsFixed(3),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(width: 0, height: 0),
                      ],
                    ),
                  ),
                ],
              );
              break;
            case 5:
              double result = avList.last.value;
              Color textCol;
              if (result >= 4) {
                textCol = Colors.green;
              } else if (result >= 3) {
                textCol = Colors.orange;
              } else if (result >= 3) {
                textCol = Colors.red[400];
              } else {
                textCol = Colors.red[900];
              }

              int performancePercentage = calcPercentFromEvalsList(
                av: result,
                evalList: getSameSubjectEvals(
                  subject: eval.subject.fullName,
                  sort: true,
                  onlyBefore: eval.date,
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
                        currentValue: result,
                        displayWidget: Text(
                          '${capitalize(getTranslatedString("inAv"))}:',
                          style: TextStyle(fontSize: 18),
                        ),
                        valueWidget: Text(
                          result.toStringAsFixed(3),
                          style: TextStyle(fontSize: 21, color: textCol),
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
                        currentValue: performancePercentage.toDouble(),
                        displayWidget: Text(
                          '${capitalize(getTranslatedString("inPc"))}:',
                          style: TextStyle(fontSize: 18),
                        ),
                        valueWidget: Text(
                          performancePercentage.toString() + "%",
                          style: TextStyle(fontSize: 21, color: textColPercent),
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
              break;
            default:
              return SizedBox(
                height: 150,
              );
              break;
          }
        },
      ),
    );
  }
}
