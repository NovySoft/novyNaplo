import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:charts_flutter/flutter.dart' as charts;

List<charts.Series<LinearMarkChartData, int>> createSubjectChart(
    List<Evals> input, String id) {
  List<LinearMarkChartData> chartData = [];
  double sum = 0;
  double index = 0;
  int listArray = 0;
  for (var n in input) {
    sum += n.szamErtek * n.sulySzazalekErteke / 100;
    index += 1 * n.sulySzazalekErteke / 100;
    chartData.add(new LinearMarkChartData(listArray, sum / index));
    listArray++;
  }
  return [
    new charts.Series<LinearMarkChartData, int>(
      id: id,
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (LinearMarkChartData marks, _) => marks.count,
      measureFn: (LinearMarkChartData marks, _) => marks.value,
      data: chartData,
    )
  ];
}
