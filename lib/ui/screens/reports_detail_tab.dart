import 'package:customgauge/customgauge.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/charts/createSubjectChart.dart';
import 'package:novynaplo/helpers/logicAndMath/calcPercentFromEvalsList.dart';
import 'package:novynaplo/helpers/logicAndMath/getSameSubjectEvals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class ReportsDetailTab extends StatelessWidget {
  ReportsDetailTab({
    @required this.eval,
    @required this.color,
    @required this.title,
    @required this.inputList,
  });

  final Evals eval;
  final Color color;
  final String title;
  final List<Evals> inputList;

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
    List<charts.Series<dynamic, num>> chartList = [];
    if (inputList.length > 0) {
      chartList = createSubjectChart(inputList, inputList[0].subject.name);
    }
    List<charts.Series<dynamic, num>> chartPointList = [];
    if (chartList != null) {
      if (chartList.length > 0) {
        avList = List.from(chartList[0].data);
        chartPointList = chartList;
      }
    }
    if (avList.length <= 0) {
      avList = [LinearMarkChartData(0, 0)];
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(capitalize(title)),
      ),
      body: ListView.builder(
        itemCount: 6 + globals.adModifier,
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
                                eval.textValue),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              );
              break;
            case 2:
              return SizedBox(
                height: 200,
                child: new charts.LineChart(
                  chartPointList,
                  behaviors: [new charts.PanAndZoomBehavior()],
                  animate: globals.chartAnimations,
                  domainAxis: axisTwo,
                  primaryMeasureAxis: axis,
                  defaultRenderer:
                      new charts.LineRendererConfig(includePoints: true),
                ),
              );
              break;
            case 3:
              return Center(
                child: Text(
                  getTranslatedString("arrowFirstMark"),
                ),
              );
              break;
            case 4:
              List<LinearMarkChartData> sortableList = List.from(avList);
              sortableList.sort((a, b) => a.value.compareTo(b.value));
              Color diffColor;
              Widget diffIcon;
              if (avList.last.value - avList.first.value == 0) {
                diffColor = Colors.orange;
                diffIcon = Icon(
                  Icons.linear_scale,
                  color: diffColor,
                );
              } else if (avList.last.value - avList.first.value < 0) {
                diffColor = Colors.red;
                diffIcon = Icon(
                  Icons.keyboard_arrow_down,
                  color: diffColor,
                );
              } else if (avList.last.value - avList.first.value > 0) {
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
                                sortableList.first.value.toStringAsFixed(3),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                            "${getTranslatedString("best")} ${getTranslatedString("av")}: " +
                                sortableList.last.value.toStringAsFixed(3),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.start,
                          children: <Widget>[
                            Text(
                                "${capitalize(title)} ${getTranslatedString("av")}: " +
                                    avList.last.value.toStringAsFixed(3),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            diffIcon,
                            Text(
                              "${(avList.last.value - avList.first.value).toStringAsFixed(3)}",
                              style: TextStyle(color: diffColor),
                            ),
                          ],
                        ),
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
                  subject: eval.subject.name,
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
                      ),
                      CustomGauge(
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
