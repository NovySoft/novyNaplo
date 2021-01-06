import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:charts_flutter/flutter.dart' as charts;

void getBarChart(input) {
  List<MarkForBars> data = [
    //WARN do not modify order!
    new MarkForBars('1', 0), //0
    new MarkForBars('2', 0), //1
    new MarkForBars('3', 0), //2
    new MarkForBars('4', 0), //3
    new MarkForBars('5', 0), //4
  ];
  for (var n in input) {
    for (var y in n) {
      switch (y.numberValue) {
        case 5:
          data[4].count++;
          break;
        case 4:
          data[3].count++;
          break;
        case 3:
          data[2].count++;
          break;
        case 2:
          data[1].count++;
          break;
        case 1:
          data[0].count++;
          break;
      }
    }
  }
  stats.howManyFromMarks = [
    new charts.Series<MarkForBars, String>(
      id: 'count',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (MarkForBars count, _) => count.name,
      measureFn: (MarkForBars count, _) => count.count,
      data: data,
      labelAccessorFn: (MarkForBars count, _) =>
          ('${count.count.toString()}db'),
    )
  ];
}
