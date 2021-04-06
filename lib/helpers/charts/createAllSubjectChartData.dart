import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/subjectColor.dart';

//TODO: Refactor
List<charts.Series<LinearMarkChartData, int>> createAllSubjectChartData(
    var allParsedInput) {
  var linearMarkDataList = [];
  List<dynamic> subjectMarks = [];
  int index = 0;
  double numVal = 0;
  double oszto = 0;
  for (var n in allParsedInput) {
    numVal = 0;
    oszto = 0;
    subjectMarks.add([]);
    subjectMarks[index].add(n[0].subject);
    for (var y in n) {
      numVal += y.numberValue * y.weight / 100;
      oszto += 1 * y.weight / 100;
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
      returnList.add(
        new LinearMarkChartData(
          locIndex - 1,
          n,
          id: list[0].name,
          subject: list[0],
        ),
      );
    }
    locIndex++;
  }
  return returnList;
}

List<charts.Series<LinearMarkChartData, int>> makeChartReturnList(var input) {
  input.removeWhere((item) => item.length == 0 || item == []);
  List<charts.Series<LinearMarkChartData, int>> returnList = [];
  List<LinearMarkChartData> tempList = [];

  for (var n in input) {
    tempList = [];
    tempList.addAll(n);
    Color subjColor = getColorBasedOnSubject(tempList[0].subject);
    charts.Color color = charts.Color(
      r: subjColor.red,
      g: subjColor.green,
      b: subjColor.blue,
      a: subjColor.alpha,
    );
    //Subject name splitting
    String subjectName = tempList[0].id;
    if (subjectName.length > globals.splitChartLength) {
      subjectName = subjectName.substring(0, globals.splitChartLength) + "...";
    }
    returnList.add(new charts.Series<LinearMarkChartData, int>(
      id: subjectName,
      colorFn: (_, __) => color,
      domainFn: (LinearMarkChartData marks, _) => marks.count,
      measureFn: (LinearMarkChartData marks, _) => marks.value,
      data: tempList,
    ));
  }
  return returnList;
}
