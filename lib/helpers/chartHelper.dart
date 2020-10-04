import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/absences_tab.dart' as absencesPage;
import 'package:novynaplo/translations/translationProvider.dart';

int index = 0;
List<LinearMarkChartData> chartData = [];

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
  index = 0;
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

//Összesített átlag
void getAllSubjectsAv(input) {
  double index = 0, sum = 0, tempIndex = 0;
  double tempValue = 0;
  stats.osszesitettAv.count = 0;
  for (var n in input) {
    tempIndex = 0;
    for (var y in n) {
      tempIndex++;
      sum += y.numberValue * double.parse(y.weight.split("%")[0]) / 100;
      index += 1 * double.parse(y.weight.split("%")[0]) / 100;
      stats.osszesitettAv.value = sum / index;
      if (tempIndex == n.length - 1) {
        tempValue = sum / index;
      }
    }
  }
  stats.osszesitettAv.count = index;
  stats.osszesitettAv.diffSinceLast = (tempValue - (sum / index)) * -1;
}

//Legjobb, legroszabb és a köztes jegyek
void getWorstAndBest(input) async {
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
  index = 0;
  List<stats.AV> tempListTwo = [];
  tempList.removeWhere((item) =>
      item.value == double.nan || item.value.isNaN || item.value == null);
  double curValue = tempList[0].value;
  stats.worstSubjectAv = tempList.last;
  stats.allSubjectsAv = tempList;
  if (tempList.length > 1) {
    //Find the better subject based on count
    while (curValue == tempList[index.toInt()].value) {
      tempListTwo.add(tempList[index.toInt()]);
      index++;
      if (index.toInt() <= tempList.length) {
        curValue = -1;
      }
    }
  } else {
    tempListTwo.add(tempList[0]);
  }
  tempListTwo.sort((a, b) => b.count.compareTo(a.count));
  stats.allSubjectsAv.removeLast();
  stats.allSubjectsAv.removeWhere((item) => item == tempListTwo[0]);
  stats.bestSubjectAv = tempListTwo[0];
  //We dont await it, cause this function is time critical
  batchInsertAvarage(createAvarageDBListFromStatisticsAvarage(
      stats.bestSubjectAv, stats.allSubjectsAv, stats.worstSubjectAv));
}

void getPieChartOrBarChart(var input) {
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
  stats.howManyFromSpecific = [
    new charts.Series<stats.LinearPiData, String>(
      id: 'howManyFromSpecific',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (stats.LinearPiData count, _) => count.id.toString(),
      measureFn: (stats.LinearPiData count, _) => count.value,
      data: tempData,
      labelAccessorFn: (stats.LinearPiData count, _) => ('${count.value}'),
    )
  ];
}

void getBarChart(input) {
  List<stats.MarkForBars> data = [
    //WARN do not modify order!
    new stats.MarkForBars('1', 0), //0
    new stats.MarkForBars('2', 0), //1
    new stats.MarkForBars('3', 0), //2
    new stats.MarkForBars('4', 0), //3
    new stats.MarkForBars('5', 0), //4
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

List<charts.Series<LinearMarkChartData, int>> createSubjectChart(
    List<Evals> input, String id) {
  chartData = [];
  double sum = 0;
  double index = 0;
  int listArray = 0;
  for (var n in input) {
    sum += n.numberValue * double.parse(n.weight.split("%")[0]) / 100;
    index += 1 * double.parse(n.weight.split("%")[0]) / 100;
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

class AbsenceChartData {
  final String name = "absences";
  final int sales;

  AbsenceChartData(this.sales);
}

List<charts.Series<AbsenceChartData, String>> createAbsencesChartData(
    List<Absence> inputList) {
  final igazolando = [
    new AbsenceChartData(
        inputList.where((n) => n.justificationState == "BeJustified").length),
  ];

  final igazolt = [
    new AbsenceChartData(
        inputList.where((n) => n.justificationState == "Justified").length),
  ];

  final igazolatlan = [
    new AbsenceChartData(
        inputList.where((n) => n.justificationState == "UnJustified").length),
  ];

  return [
    new charts.Series<AbsenceChartData, String>(
      id: getTranslatedString("Justified"),
      seriesColor: charts.MaterialPalette.green.shadeDefault,
      domainFn: (AbsenceChartData sales, _) => sales.name,
      measureFn: (AbsenceChartData sales, _) => sales.sales,
      data: igazolt,
    ),
    new charts.Series<AbsenceChartData, String>(
      id: getTranslatedString("BeJustified"),
      seriesColor: charts.MaterialPalette.yellow.shadeDefault,
      domainFn: (AbsenceChartData sales, _) => sales.name,
      measureFn: (AbsenceChartData sales, _) => sales.sales,
      data: igazolando,
    ),
    new charts.Series<AbsenceChartData, String>(
      id: getTranslatedString("UnJustified"),
      seriesColor: charts.MaterialPalette.red.shadeDefault,
      domainFn: (AbsenceChartData sales, _) => sales.name,
      measureFn: (AbsenceChartData sales, _) => sales.sales,
      data: igazolatlan,
    ),
  ];
}

class AbsencesBarChart extends StatelessWidget {
  final void Function() callback;
  AbsencesBarChart({this.callback});

  final axis = charts.NumericAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
    fontSize: 10,
    color: charts.MaterialPalette.blue.shadeDefault,
  )));

  @override
  Widget build(BuildContext context) {
    var seriesList = createAbsencesChartData(absencesPage.absencesList);
    // For horizontal bar charts, set the [vertical] flag to false.
    return new charts.BarChart(
      seriesList,
      animate: globals.chartAnimations,
      barGroupingType: charts.BarGroupingType.stacked,
      vertical: false,
      primaryMeasureAxis: axis,
      domainAxis: new charts.OrdinalAxisSpec(
          // Make sure that we draw the domain axis line.
          showAxisLine: true,
          // But don't draw anything else.
          renderSpec: new charts.NoneRenderSpec()),
      selectionModels: [
        new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            updatedListener: _absencesChartSelectUpdated)
      ],
      behaviors: [
        new charts.SeriesLegend(
          outsideJustification: charts.OutsideJustification.endDrawArea,
        ),
      ],
    );
  }

  void _absencesChartSelectUpdated(charts.SelectionModel<String> model) {
    //open animatedcontainer
    if (model.hasAnySelection) {
      if (callback == null) return;
      callback();
    }
  }
}
