import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:charts_flutter/flutter.dart' as charts;

List<charts.Series<LinearMarkChartData, int>> createSubjectChart(
    List<Evals> input, String id) {
  List<Evals> manipulableData = List.from(input);
  manipulableData.sort((a, b) => a.date.compareTo(b.date));
  List<LinearMarkChartData> chartData = [];
  double sum = 0;
  double index = 0;
  int listArray = 0;
  bool isSzovegesOnly = manipulableData.indexWhere((element) =>
              element.valueType.name != "Szazalekos" &&
              element.valueType.name != "Szoveges") ==
          -1
      ? true
      : false;
  for (var n in manipulableData) {
    if (!Evals.nonAvTypes.contains(n.type.name) ||
        n.kindOf == "Magatartas" ||
        n.kindOf == "Szorgalom") {
      if (n.valueType.name == "Szazalekos" ) {
        if (isSzovegesOnly) {
          //Convert percentage mark to a normal one
          double markValue = (n.numberValue / 100) * 5;
          if (markValue < 1) {
            markValue = 1;
          }
          sum += markValue;
          index += 1; //Counts as 100%
        }
      } else {
        sum += n.numberValue * n.weight / 100;
        index += 1 * n.weight / 100;
      }
      chartData.add(new LinearMarkChartData(listArray, sum / index));
      listArray++;
    }
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
