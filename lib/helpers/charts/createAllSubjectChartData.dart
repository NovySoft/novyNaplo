import 'package:novynaplo/data/models/chartData.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/helpers/logicAndMath/getRandomBetween.dart';

List<charts.Series<LinearMarkChartData, int>> createAllSubjectChartData(
    var allParsedInput) {
  var linearMarkDataList = [];
  List<dynamic> subjectMarks = [];
  int index = 0;
  double numVal = 0;
  double oszto = 0;
  for (var y in allParsedInput) {
    numVal = 0;
    oszto = 0;
    subjectMarks.add([]);
    subjectMarks[index].add(y[0].subject);
    for (var n in y) {
      numVal += n.szamErtek * double.parse(n.weight.split("%")[0]) / 100;
      oszto += 1 * double.parse(n.weight.split("%")[0]) / 100;
      subjectMarks[index].add(numVal / oszto);
    }
    index++;
  }
  index = 0;
  for (var n in subjectMarks) {
    linearMarkDataList.add(makeLinearMarkChartData(n));
    index++;
  }
  return makeChartReturnList(linearMarkDataList);
}

List<LinearMarkChartData> makeLinearMarkChartData(var list) {
  List<LinearMarkChartData> returnList = [];
  int locIndex = 0;
  for (var n in list) {
    if (locIndex != 0 && !n.isNaN) {
      returnList.add(new LinearMarkChartData(locIndex - 1, n, id: list[0]));
    }
    locIndex++;
  }
  return returnList;
}

List<charts.Series<LinearMarkChartData, int>> makeChartReturnList(var input) {
  input.removeWhere((item) => item.length == 0 || item == []);
  List<charts.Series<LinearMarkChartData, int>> returnList = [];
  List<LinearMarkChartData> tempList = [];
  var chartTempList = [
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
  // ignore: unused_local_variable
  int index = 0;
  for (var n in input) {
    tempList = [];
    for (var y in n) {
      tempList.add(y);
    }
    if (chartTempList.length == 0) {
      chartTempList = [
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
    }
    var rndInt = getRandomIntBetween(0, chartTempList.length);
    var color = chartTempList[rndInt];
    chartTempList.removeAt(rndInt);
    returnList.add(new charts.Series<LinearMarkChartData, int>(
        id: tempList[0].id,
        colorFn: (_, __) => color,
        domainFn: (LinearMarkChartData marks, _) => marks.count,
        measureFn: (LinearMarkChartData marks, _) => marks.value,
        data: tempList));
    index++;
  }
  return returnList;
}
