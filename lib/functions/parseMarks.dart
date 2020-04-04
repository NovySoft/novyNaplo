import 'dart:core';
import 'utils.dart';
import 'classManager.dart';
import 'package:charts_flutter/flutter.dart' as charts;

List<ChartPoints> chartData = [];
var index, sum;
var jegyek;
List<Evals> jegyArray = [];
var atlagArray = [];
var noticesArray = [];
var stringEvals = [];
var catIndex = 0;

List<dynamic> parseAllByDate(var input) {
  jegyArray = [];
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    id = 0;
    jegyek.forEach((n) => jegyArray.add(setEvals(n)));
  } on Error catch (e) {
    return [e];
  }
  jegyArray.sort((a, b) => b.createDateString.compareTo(a.createDateString));
  return jegyArray;
}

List<dynamic> parseAllBySubject(var input) {
  jegyArray = [];
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    id = 0;
    jegyek.forEach((n) => jegyArray.add(setEvals(n)));
  } on Error catch (e) {
    return [e];
  }
  jegyArray = sortByDateAndSubject(jegyArray);
  return jegyArray;
}

List<String> parseMarksByDate(var input) {
  List<String> evalArray = [];
  var evalJegy = parseAllByDate(input);
  if (evalJegy[0] == "Error") return ["Error"];
  evalJegy.forEach((n) => evalArray.add(capitalize(n.subject + " " + n.value)));
  return evalArray;
}

List<String> parseMarksBySubject(var input) {
  List<String> evalArray = [];
  var evalJegy = parseAllBySubject(input);
  if (evalJegy[0] == "Error") return ["Error"];
  evalJegy.forEach((n) => evalArray.add(capitalize(n.subject + " " + n.value)));
  return evalArray;
}

List<dynamic> parseAvarages(var input) {
  atlagArray = [];
  try {
    input.forEach((n) => atlagArray.add(setAvarage(
        n["Subject"], n["Value"], n["classValue"], n["Difference"])));
  } on Error catch (e) {
    return [e.toString()];
  }
  return atlagArray;
}

int countAvarages(var input) {
  var count = 0;
  for (var n in input) {
    count++;
  }
  return count;
}

int countNotices(var input) {
  var count = 0;
  var notices = input["Notes"];
  notices.forEach((n) => count++);
  return count;
}

List<dynamic> parseNotices(var input) {
  if (input["Notes"] != null) {
    noticesArray = [];
    var notices = input["Notes"];
    notices.forEach((n) => noticesArray.add(setNotices(n)));
    return noticesArray;
  } else {
    return null;
  }
}

List<String> parseSubjects(var input) {
  List<String> subjectsArray = [];
  var subjects = input["SubjectAverages"];
  subjects.forEach((n) => subjectsArray.add(capitalize(n["Subject"])));
  return subjectsArray;
}

List<charts.Series<ChartPoints, int>> createSubjectChart(
    List<Evals> input, String id) {
  chartData = [];
  double sum = 0;
  double index = 0;
  int listArray = 0;
  for(var n in input){
      sum += n.numberValue * double.parse(n.weight.split("%")[0]) / 100;
      index += 1 * double.parse(n.weight.split("%")[0]) / 100;
      chartData.add(new ChartPoints(listArray,sum / index));
      listArray++;
  }
  return [
    new charts.Series<ChartPoints, int>(
      id: id,
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (ChartPoints marks, _) => marks.count,
      measureFn: (ChartPoints marks, _) => marks.value,
      data: chartData,
    )
  ];
}

class ChartPoints {
  var count;
  var value;

  ChartPoints(this.count, this.value);
}

//USED BY STATISTICS
List<dynamic> categorizeSubjects(var input) {
  var parsed = input["Evaluations"];
  List<Evals> jegyArray = [];
  List<List<Evals>> jegyMatrix = [[]];
  var output = [];
  for (var n in parsed) {
    jegyArray.add(setEvals(n));
  }
  jegyArray.sort((a, b) => a.subject.compareTo(b.subject));
  String lastString = "";
  for (var n in jegyArray) {
    if ((n.form != "Percent" && n.type != "HalfYear") ||
        n.subject == "Magatartas" ||
        n.subject == "Szorgalom") {
      if (n.subject != lastString) {
        jegyMatrix.add([]);
        lastString = n.subject;
      }
      jegyMatrix.last.add(n);
    }
  }
  jegyMatrix.removeAt(0);
  int index = 0;
  for(var n in jegyMatrix){
    n.sort((a, b) => a.createDate.compareTo(b.createDate));
    index++;
  }
  return jegyMatrix;
}

List<dynamic> sortByDateAndSubject(List<dynamic> input) {
  input.sort((a, b) => a.subject.compareTo(b.subject));
  int _currentIndex = 0;
  String _beforeSubject = input[0].subject;
  List<Evals> _output = [];
  List<List<Evals>> _tempArray = [[]];
  for (var n in input) {
    if (n.subject != _beforeSubject) {
      _currentIndex++;
      _tempArray.add([]);
      _beforeSubject = n.subject;
    }
    _tempArray[_currentIndex].add(n);
  }
  for (List<Evals> n in _tempArray) {
    n.sort((a, b) => b.createDateString.compareTo(a.createDateString));
    for (var x in n) {
      _output.add(x);
    }
  }
  return _output;
}
