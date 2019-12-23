import 'dart:core';
import 'utils.dart';
import 'classManager.dart';
import 'package:charts_flutter/flutter.dart' as charts;
List<ChartPoints> chartData = [];
var index,sum;
var jegyek;
var jegyArray = [];
var atlagArray = [];
var noticesArray = [];
var stringEvals = [];
var catIndex = 0;

List<dynamic> parseAll(var input) {
  jegyArray = [];
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    id = 0;
    jegyek.forEach((n) => jegyArray.add(setEvals(n)));
  } on Error catch (e) {
    return [e];
  }
  return jegyArray;
}

List<String> parseMarks(var input) {
  List<String> evalArray = [];
  var evalJegy = parseAll(input);
  if (evalJegy[0] == "Error") return ["Error"];
  evalJegy.forEach((n) => evalArray.add(capitalize(n.subject + " " + n.value)));
  return evalArray;
}

List<dynamic> parseAvarages(var input) {
  atlagArray = [];
  try {
    var atlagok = input["SubjectAverages"];
    atlagok.forEach((n) => atlagArray.add(setAvarage(
        n["Subject"], n["Value"], n["classValue"], n["Difference"])));
  } on Error catch (e) {
    return [e.toString()];
  }
  return atlagArray;
}

int countAvarages(var input) {
  var count = 0;
  var atlagok = input["SubjectAverages"];
  atlagok.forEach((n) => count++);
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
  }
}

List<String> parseSubjects(var input) {
  List<String> subjectsArray = [];
  var subjects = input["SubjectAverages"];
  subjects.forEach((n) => subjectsArray.add(capitalize(n["Subject"])));
  return subjectsArray;
}

List<charts.Series<ChartPoints, int>> createSubjectChart(List<int> input, String id) {
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

void addChartPoints(var n){
  sum += n;
  chartData.add(new ChartPoints(index-1,sum/index));
  index++;
}

List<dynamic> categorizeSubjects(var input){
  catIndex = 0;
  var arrayIndex = 1;
  var parsed = parseAll(input);
  var strings = [];
  var stringsTwo = [];
  var output = [[]];
  String subJect = ""; //will store temp data
  for(var n in parsed){
    var date = n.date.split("T")[0];
    var subject = n.subject;
    var value = n.numberValue;
    if(n.form != "Percent"){
      strings.add(subject + ":" + date + ":" + value.toString());
      stringsTwo.add(date + ":" + subject + ":" + value.toString());
    } 
  }
  strings.sort();
  stringsTwo.sort();
  for(var n in stringsTwo){
    output[0].add("Összesített átlag:" + n.split(":")[2]);
  }
  output.add([]);
  for(var n in strings){
    if(catIndex != 0 && subJect != n.split(":")[0]){
      output.add([]);
      arrayIndex++;
    }
    output[arrayIndex].add(n.split(":")[0] + ":" + n.split(":")[2]);
    subJect = n.split(":")[0];
    catIndex++;
  }
  return output;
}