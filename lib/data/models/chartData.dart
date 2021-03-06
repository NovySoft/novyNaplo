import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/data/models/subject.dart';

var chartColorList = [
  charts.MaterialPalette.green.shadeDefault,
  charts.MaterialPalette.blue.shadeDefault,
  charts.MaterialPalette.red.shadeDefault,
  charts.MaterialPalette.deepOrange.shadeDefault,
  charts.MaterialPalette.lime.shadeDefault,
  charts.MaterialPalette.purple.shadeDefault,
  charts.MaterialPalette.cyan.shadeDefault,
  charts.MaterialPalette.yellow.shadeDefault,
  charts.MaterialPalette.indigo.shadeDefault,
  charts.MaterialPalette.pink.shadeDefault,
  charts.MaterialPalette.teal.shadeDefault,
];

class AbsenceChartData {
  final String name;
  final int count;

  AbsenceChartData(this.name, this.count);
}

class LinearMarkChartData {
  final int count;
  final double value;
  String id;
  Subject subject;

  LinearMarkChartData(this.count, this.value, {this.id, this.subject});

  @override
  String toString() {
    return "${this.id}: ${this.count} ${this.value}";
  }
}

class LinearPieData {
  final int id;
  final int value;
  final String name;

  LinearPieData(this.id, this.value, this.name);
}

class MarkForBars {
  final String name;
  int count;

  MarkForBars(this.name, this.count);
}

class ChartReturn {
  List<charts.Series<LinearMarkChartData, int>> points;
  double halfYearMarker;

  ChartReturn(this.points, this.halfYearMarker);
}
