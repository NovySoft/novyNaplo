import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:charts_flutter/flutter.dart' as charts;

var axis = charts.NumericAxisSpec(
    renderSpec: charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
          fontSize: 10, color: charts.MaterialPalette.white),
      //chnage white color as per your requirement.
    ));

var axisTwo = charts.NumericAxisSpec(
    renderSpec: charts.SmallTickRendererSpec(
      labelStyle: charts.TextStyleSpec(
          fontSize: 10, color: charts.MaterialPalette.white),
      
      //chnage white color as per your requirement.
    ));

class ChartsDetailTab extends StatelessWidget {
  const ChartsDetailTab(
      {this.subject,
      this.color,
      this.id,
      this.avList,
      this.seriesList,
      this.animate});

  final int id;
  final String subject;
  final MaterialColor color;
  final List<dynamic> avList;
  final List<charts.Series> seriesList;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: body(),
    );
  }

  Widget body() {
    return SafeArea(
        bottom: false,
        left: false,
        right: false,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            height: 60,
            child: DecoratedBox(
                decoration: BoxDecoration(color: color),
                child: Center(
                  child: Text(
                    subject,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                )),
          ),
          new Expanded(
            child: charts.LineChart(
              seriesList,
              behaviors: [new charts.PanAndZoomBehavior()],
              animate: animate,
              domainAxis: axisTwo,
              primaryMeasureAxis: axis,
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
            ),
          )
        ]));
  }
}
