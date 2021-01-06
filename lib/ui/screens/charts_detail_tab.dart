import 'package:charts_flutter/flutter.dart' as charts;
import 'package:customgauge/customgauge.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/calcPercentFromEvalsList.dart';
import 'package:novynaplo/helpers/logicAndMath/getSameSubjectEvals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class ChartsDetailTab extends StatelessWidget {
  ChartsDetailTab({
    this.subject,
    this.color,
    this.id,
    this.seriesList,
    this.animate,
  });

  final int id;
  final String subject;
  final Color color;
  final List<charts.Series> seriesList;
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
      appBar: AppBar(),
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
                        color: Colors.black,
                      ),
                    ),
                  )),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 2 + globals.adModifier,
                itemBuilder: (BuildContext context, int index) {
                  switch (index) {
                    case 0:
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
                                  style: TextStyle(
                                      fontSize: 21, color: textColPercent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                      break;
                    case 1:
                      return SizedBox(
                          height: 500,
                          child: new charts.LineChart(
                            seriesList,
                            behaviors: [new charts.PanAndZoomBehavior()],
                            animate: animate,
                            domainAxis: axisTwo,
                            primaryMeasureAxis: axis,
                            defaultRenderer: new charts.LineRendererConfig(
                                includePoints: true),
                          ));
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
