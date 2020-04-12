import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/screens/calculator_tab.dart' as calc;
import 'package:novynaplo/screens/statistics_tab.dart' as stats;

//TODO optimize this entire thing
class LinearMarkChartData {
  final int count;
  final double value;
  String id;

  LinearMarkChartData(this.count, this.value, {this.id});
}

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

dynamic createOsszesitett(var allParsedInput) {
  double sum = 0, index = 0;
  var tempList = [];
  for (var n in allParsedInput) {
    for (var y in n) {
      sum += y.numberValue * double.parse(y.weight.split("%")[0]) / 100;
      index += 1 * double.parse(y.weight.split("%")[0]) / 100;
      tempList.add(sum / index);
    }
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
      numVal += n.numberValue * double.parse(n.weight.split("%")[0]) / 100;
      oszto += 1 * double.parse(n.weight.split("%")[0]) / 100;
      subjectMarks[index].add(numVal / oszto);
    }
    index++;
  }
  index = 0;
  for (var n in subjectMarks) {
    linearMarkDataList.add(makeChartPoints(n));
    index++;
  }
  return makeChartReturnList(linearMarkDataList);
}

List<LinearMarkChartData> makeChartPoints(var list) {
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
    var rndInt = getRandomBetween(0, chartTempList.length);
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

int getRandomBetween(int min, int max) {
  final _random = new Random();
  return min + _random.nextInt(max - min);
}

void getAllSubjectsAv(input) {
  double index = 0, sum = 0, tempIndex = 0;
  double tempValue = 0;
  stats.globalAllSubjectAv.count = 0;
  for (var n in input) {
    tempIndex = 0;
    for (var y in n) {
      tempIndex++;
      sum += y.numberValue * double.parse(y.weight.split("%")[0]) / 100;
      index += 1 * double.parse(y.weight.split("%")[0]) / 100;
      stats.globalAllSubjectAv.value = sum / index;
      if (tempIndex == n.length - 1) {
        tempValue = sum / index;
      }
    }
  }
  stats.globalAllSubjectAv.count = index;
  stats.globalAllSubjectAv.diffSinceLast = (tempValue - (sum / index)) * -1;
}

void getWorstAndBest(input) {
  List<stats.AV> tempList = [];
  double sum = 0, index = 0;
  int listIndex = 0;
  for (var n in input) {
    index = 0;
    sum = 0;
    if (n.length == 1) {
      listIndex = 0;
    } else {
      listIndex = 1;
    }
    stats.AV temp = new stats.AV();
    for (var y in n) {
      sum += y.numberValue * double.parse(y.weight.split("%")[0]) / 100;
      index += 1 * double.parse(y.weight.split("%")[0]) / 100;
      if (listIndex == n.length - 1) {
        temp.diffSinceLast = sum / index;
      }
      listIndex++;
    }
    temp.value = sum / index;
    temp.count = index.toDouble();
    temp.subject = n[0].subject;
    temp.diffSinceLast = (temp.diffSinceLast - (sum / index)) * -1;
    tempList.add(temp);
  }
  tempList.sort((a, b) =>
      b.value.toStringAsFixed(3).compareTo(a.value.toStringAsFixed(3)));
  stats.worstSubjectAv = tempList.last;
  index = 0;
  List<stats.AV> tempListTwo = [];
  tempList.removeWhere((item) => item.value == double.nan || item.value.isNaN);
  double curValue = tempList[0].value;
  if (tempList.length > 1) {
    while (curValue == tempList[index.toInt()].value) {
      tempListTwo.add(tempList[index.toInt()]);
      index++;
    }
  } else {
    tempListTwo.add(tempList[0]);
  }
  tempListTwo.sort((a, b) => b.count.compareTo(a.count));
  stats.bestSubjectAv = tempListTwo[0];
}

void getPieChart(var input) {
  List<stats.LinearPiData> tempData = [];
  int index = 0;
  String name = "";
  for (var n in input) {
    if (n[0].subject.startsWith("magyar")) {
      name = n[0].subject.split(" ")[1];
    } else {
      name = n[0].subject;
    }
    tempData.add(new stats.LinearPiData(index, n.length, name));
    index++;
  }
  tempData.sort((a, b) => a.value.compareTo(b.value));
  stats.pieList = [
    new charts.Series<stats.LinearPiData, int>(
      id: 'MarksCountPie',
      colorFn: (_, index) {
        return charts.MaterialPalette.blue.shadeDefault;
      },
      domainFn: (stats.LinearPiData sales, _) => sales.id,
      measureFn: (stats.LinearPiData sales, _) => sales.value,
      data: tempData,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (stats.LinearPiData row, _) =>
          '${row.name}: ${row.value}',
    )
  ];
}

void getBarChart(input) {
  List<stats.MarkForBars> data = [
    //WARN do not modify order!
    new stats.MarkForBars('1es', 0), //0
    new stats.MarkForBars('2es', 0), //1
    new stats.MarkForBars('3as', 0), //2
    new stats.MarkForBars('4es', 0), //3
    new stats.MarkForBars('5ös', 0), //4
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
    new charts.Series<stats.MarkForBars, String>(
      id: 'count',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (stats.MarkForBars count, _) => count.name,
      measureFn: (stats.MarkForBars count, _) => count.count,
      data: data,
      labelAccessorFn: (stats.MarkForBars count, _) =>
          ('${count.count.toString()}db'),
    )
  ];
}
