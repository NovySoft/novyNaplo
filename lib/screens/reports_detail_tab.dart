import 'package:customgauge/customgauge.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'package:novynaplo/translations/translationProvider.dart';

class ReportsDetailTab extends StatelessWidget {
  ReportsDetailTab({
    @required this.eval,
    @required this.color,
    @required this.title,
    @required this.chartList,
  });

  final Evals eval;
  final Color color;
  final String title;
  final List<charts.Series> chartList;

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
    List<ChartPoints> avList = List.from(chartList[0].data);
    if (avList.length == 0) avList = [ChartPoints(0, 0), ChartPoints(1, 0)];
    return Scaffold(
      appBar: AppBar(
        title: Text(capitalize(title)),
      ),
      body: ListView.builder(
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
                  children: [
                    SizedBox(height: 5),
                    Text(
                      capitalize((eval.theme.toLowerCase() == "dicséret" ||
                                  eval.theme.toLowerCase() == "kitűnő"
                              ? "${getTranslatedString("praiseworthy")} "
                              : "") +
                          eval.subject +
                          " " +
                          eval.value),
                      style: TextStyle(fontSize: 20),
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
                  chartList,
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
              List<ChartPoints> sortableList = List.from(avList);
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15),
                  Text(
                      "${getTranslatedString("worst")} ${getTranslatedString("av")}: " +
                          sortableList.first.value.toStringAsFixed(3),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                      "${getTranslatedString("best")} ${getTranslatedString("av")}: " +
                          sortableList.last.value.toStringAsFixed(3),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
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
              );
              break;
            case 5:
              var result = avList.map((m) => m.value).reduce((a, b) => a + b) /
                  avList.length;
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
                evalList: getSameSubjectEvals(
                  subject: eval.subject,
                  sort: true,
                  onlyBefore: eval.createDate,
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
                          style: TextStyle(fontSize: 21),
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
                          style: TextStyle(fontSize: 21),
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
          }
        },
      ),
    );
  }
}
