import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:charts_flutter/flutter.dart' as charts;

void getPieChartOrBarChart(var input) {
  List<LinearPieData> tempData = [];
  int index = 0;
  String name = "";
  for (var n in input) {
    if (n[0].subject.name.startsWith("magyar")) {
      name = n[0].subject.name.split(" ")[1];
    } else {
      name = n[0].subject.name;
    }
    tempData.add(new LinearPieData(index, n.length, name));
    index++;
  }
  tempData.sort((a, b) => a.value.compareTo(b.value));
  stats.pieList = [
    new charts.Series<LinearPieData, int>(
      id: 'MarksCountPie',
      colorFn: (_, index) {
        return charts.MaterialPalette.blue.shadeDefault;
      },
      domainFn: (LinearPieData sales, _) => sales.id,
      measureFn: (LinearPieData sales, _) => sales.value,
      data: tempData,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (LinearPieData row, _) => '${row.name}: ${row.value}',
    )
  ];
  stats.howManyFromSpecific = [
    new charts.Series<LinearPieData, String>(
      id: 'howManyFromSpecific',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (LinearPieData count, _) => count.id.toString(),
      measureFn: (LinearPieData count, _) => count.value,
      data: tempData,
      labelAccessorFn: (LinearPieData count, _) => ('${count.value}'),
    )
  ];
}
