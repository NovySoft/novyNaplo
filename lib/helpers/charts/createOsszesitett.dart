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
    if (a.createDate.year == b.createDate.year &&
        a.createDate.month == b.createDate.month &&
        a.createDate.day == b.createDate.day) {
      return a.createDate.toString().compareTo(b.createDate.toString());
    } else {
      return a.giveUpDate.compareTo(b.giveUpDate);
    }
  });
  for (var n in interatorList) {
    sum += n.numberValue * n.weight / 100;
    index += 1 * n.weight / 100;
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
