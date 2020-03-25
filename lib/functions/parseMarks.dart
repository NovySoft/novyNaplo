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
  }else{
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
    List<int> input, String id) {
  chartData = [];
  index = 1;
  sum = 0;
  input.forEach((n) => addChartPoints(n));
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

void addChartPoints(var n) {
  sum += n;
  chartData.add(new ChartPoints(index - 1, sum / index));
  index++;
}

List<dynamic> categorizeSubjects(var input) {
  //TODO rewrite with matrixes
  catIndex = 0;
  var arrayIndex = 1;
  var parsed = parseAllByDate(input);
  var strings = [];
  var stringsTwo = [];
  var output = [[]];
  String subJect = ""; //will store temp data
  for (var n in parsed) {
    var date = n.dateString.split("T")[0];
    var subject = n.subject;
    var value = n.numberValue;
    if ((n.form != "Percent" && n.type != "HalfYear") ||
        subject == "Magatartas" ||
        subject == "Szorgalom") {
      strings.add(subject + ":" + date + ":" + value.toString());
      stringsTwo.add(date + ":" + subject + ":" + value.toString());
    }
  }
  strings.sort();
  stringsTwo.sort();
  for (var n in stringsTwo) {
    output[0].add("Összesített átlag:" + n.split(":")[2]);
  }
  output.add([]);
  for (var n in strings) {
    if (catIndex != 0 && subJect != n.split(":")[0]) {
      output.add([]);
      arrayIndex++;
    }
    output[arrayIndex].add(n.split(":")[0] + ":" + n.split(":")[2]);
    subJect = n.split(":")[0];
    catIndex++;
  }
  return output;
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