import 'package:charts_flutter/flutter.dart' as charts;
import 'package:customgauge/customgauge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';

class ChartsDetailTab extends StatelessWidget {
  ChartsDetailTab(
      {this.subject, this.color, this.id, this.seriesList, this.animate});

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
    globals.globalContext = context;
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
        bottom: false,
        left: false,
        right: false,
        child: ListView.builder(
            itemCount: 3 + globals.adModifier,
            itemBuilder: (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return SizedBox(
                    height: 60,
                    child: DecoratedBox(
                        decoration: BoxDecoration(color: color),
                        child: Center(
                          child: Text(
                            subject,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25),
                          ),
                        )),
                  );
                  break;
                case 1:
                  return Center(
                      child: CustomGauge(
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
                            style: TextStyle(fontSize: 21),
                          ),
                          valueWidget: Text(
                              seriesList.last.data.last.value
                                  .toStringAsFixed(3),
                              style: TextStyle(fontSize: 21, color: textCol))));
                  break;
                case 2:
                  return SizedBox(
                      height: 500,
                      child: new charts.LineChart(
                        seriesList,
                        behaviors: [new charts.PanAndZoomBehavior()],
                        animate: animate,
                        domainAxis: axisTwo,
                        primaryMeasureAxis: axis,
                        defaultRenderer:
                            new charts.LineRendererConfig(includePoints: true),
                      ));
                  break;
                default:
                  return SizedBox(
                    height: 50,
                  );
              }
            }),
      ),
    );
  }
}
