import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

ChartReturn createSubjectChart(List<Evals> input, String id, bool lightmode) {
  List<Evals> manipulableData = List.from(input);
  manipulableData.sort((a, b) => a.date.compareTo(b.date));
  List<LinearMarkChartData> chartData = [];
  List<LinearMarkChartData> classAvData = [];
  double sum = 0;
  double index = 0;
  int listArray = 0;
  bool isSzovegesOnly = manipulableData.indexWhere((element) =>
              element.valueType.name != "Szazalekos" &&
              element.valueType.name != "Szoveges" &&
              element.valueType.name != "SzazalekosAtszamolt") ==
          -1
      ? true
      : false;
  for (var n in manipulableData) {
    if (!Evals.nonAvTypes.contains(n.type.name) ||
        n.kindOf == "Magatartas" ||
        n.kindOf == "Szorgalom") {
      if (n.valueType.name == "Szazalekos" ||
          n.valueType.name == "SzazalekosAtszamolt" ||
          n.valueType.name == "Szoveges") {
        if (isSzovegesOnly) {
          double markValue = n.numberValue;
          //Convert percentage mark to a normal one
          if (n.valueType.name == "Szazalekos") {
            markValue = (n.numberValue / 100) * 5;
          }
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
      if (n.classAv != null) {
        classAvData.add(new LinearMarkChartData(listArray, n.classAv));
      }
      listArray++;
    }
  }
  charts.Color classAvColor = charts.Color(
    r: 255,
    g: 255,
    b: 0,
    a: 128,
  );
  if (lightmode) {
    classAvColor = charts.Color(
      r: 251,
      g: 192,
      b: 45,
      a: 128,
    );
  }
  return ChartReturn([
    new charts.Series<LinearMarkChartData, int>(
      id: id,
      colorFn: (_, __) => classAvColor,
      domainFn: (LinearMarkChartData marks, _) => marks.count,
      measureFn: (LinearMarkChartData marks, _) => marks.value,
      data: classAvData,
    ),
    new charts.Series<LinearMarkChartData, int>(
      id: id,
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (LinearMarkChartData marks, _) => marks.count,
      measureFn: (LinearMarkChartData marks, _) => marks.value,
      data: chartData,
    )
  ], stats.halfYearMarkers[manipulableData[0].subject.fullName]);
}
