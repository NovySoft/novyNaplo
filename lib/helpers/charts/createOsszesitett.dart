import 'package:novynaplo/data/models/chartData.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';

dynamic createOsszesitett(List<List<Evals>> allParsedInput) {
  double sum = 0, index = 0;
  var tempList = [];
  //Convert 2D data to 1D array
  List<dynamic> interatorList =
      List.from(allParsedInput).expand((i) => i).toList();
  interatorList.sort((a, b) {
    //!LOOK INTO WHY EXTENSION METHODS ARENT WORKING HERE
    if (a.rogzitesDatuma.year == b.rogzitesDatuma.year &&
        a.rogzitesDatuma.month == b.rogzitesDatuma.month &&
        a.rogzitesDatuma.day == b.rogzitesDatuma.day) {
      return a.keszitesDatuma.compareTo(b.keszitesDatuma);
    } else {
      return a.rogzitesDatuma.compareTo(b.rogzitesDatuma);
    }
  });
  for (var n in interatorList) {
    sum += n.szamErtek * n.sulySzazalekErteke / 100;
    index += 1 * n.sulySzazalekErteke / 100;
    tempList.add(sum / index);
  }

  List<LinearMarkChartData> tempListTwo = [];
  index = 0;
  for (var n in tempList) {
    tempListTwo.add(new LinearMarkChartData(index.toInt(), n, id: "Minden"));
    index++;
  }

  return [
    new charts.Series<LinearMarkChartData, int>(
        id: tempListTwo[0].id,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearMarkChartData marks, _) => marks.count,
        measureFn: (LinearMarkChartData marks, _) => marks.value,
        data: tempListTwo)
  ];
}
