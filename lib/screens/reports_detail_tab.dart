import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/global.dart' as globals;

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
                              ? "Dicséretes "
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
                  height: 500,
                  child: new charts.LineChart(
                    chartList,
                    behaviors: [new charts.PanAndZoomBehavior()],
                    animate: globals.chartAnimations,
                    domainAxis: axisTwo,
                    primaryMeasureAxis: axis,
                    defaultRenderer:
                        new charts.LineRendererConfig(includePoints: true),
                  ));
              break;
          }
        },
      ),
    );
  }
}
