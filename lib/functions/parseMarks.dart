import 'dart:core';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'classManager.dart';
import 'utils.dart';

List<ChartPoints> chartData = [];
var index, sum;
var jegyek;
List<Evals> jegyArray = [];
var stringEvals = [];
var catIndex = 0;

List<dynamic> parseAllByDate(var input) {
  jegyArray = [];
  //! TODO fix this duplicate code
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    for (var n in jegyek) {
      jegyArray.add(setEvals(n));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAllByDate');
    return [];
  }
  jegyArray.sort((a, b) => b.createDateString.compareTo(a.createDateString));
  batchInsertEval(jegyArray);
  return jegyArray;
}

List<dynamic> parseAllBySubject(var input) {
  jegyArray = [];
  //! TODO fix this duplicate code
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    for (var n in jegyek) {
      jegyArray.add(setEvals(n));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAllBySubject');
    return [];
  }
  jegyArray = sortByDateAndSubject(jegyArray);
  return jegyArray;
}

List<String> parseMarksByDate(var input) {
  List<String> evalArray = [];
  if (input != null) {
    var evalJegy = parseAllByDate(input);
    if (evalJegy.length == 0) return [];
    if (evalJegy[0] == "Error") return ["Error"];
    for (var n in evalJegy) {
      evalArray.add(capitalize(n.subject + " " + n.value));
    }
  }
  return evalArray;
}

List<String> parseMarksBySubject(var input) {
  List<String> evalArray = [];
  if (input != null) {
    var evalJegy = parseAllBySubject(input);
    if (evalJegy.length == 0) return [];
    if (evalJegy[0] == "Error") return ["Error"];
    for (var n in evalJegy) {
      evalArray.add(capitalize(n.subject + " " + n.value));
    }
  }
  return evalArray;
}

List<Avarage> parseAvarages(var input) {
  List<Avarage> atlagArray = [];
  try {
    for (var n in input) {
      atlagArray.add(setAvarage(
          n["Subject"], n["Value"], n["classValue"], n["Difference"]));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAvarages');
    return [];
  }
  batchInsertAvarage(atlagArray);
  return atlagArray;
}

int countNotices(var input) {
  int count = 0;
  if (input != null && input["Notes"] != null) {
    var notices = input["Notes"];
    count = notices.length;
  }
  return count;
}

List<Notices> parseNotices(var input) {
  if (input != null && input["Notes"] != null) {
    List<Notices> noticesArray = [];
    var notices = input["Notes"];
    for (var n in notices) {
      noticesArray.add(setNotices(n));
    }
    batchInsertNotices(noticesArray);
    return noticesArray;
  } else {
    return [];
  }
}

List<String> parseSubjects(var input) {
  List<String> subjectsArray = [];
  var subjects = input["SubjectAverages"];
  for (var n in subjects) {
    subjectsArray.add(capitalize(n["Subject"]));
  }
  return subjectsArray;
}

//TODO move this code to the chartHelper file
//!FROM here
List<charts.Series<ChartPoints, int>> createSubjectChart(
    List<Evals> input, String id) {
  chartData = [];
  double sum = 0;
  double index = 0;
  int listArray = 0;
  for (var n in input) {
    sum += n.numberValue * double.parse(n.weight.split("%")[0]) / 100;
    index += 1 * double.parse(n.weight.split("%")[0]) / 100;
    chartData.add(new ChartPoints(listArray, sum / index));
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
//!TO here

//TODO probably we should move this to somewhere else
//*USED BY STATISTICS
List<dynamic> categorizeSubjects(var input) {
  var parsed = input["Evaluations"];
  List<Evals> jegyArray = [];
  List<List<Evals>> jegyMatrix = [[]];
  if (input != [] && input != null && parsed != null && parsed != []) {
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
    for (var n in jegyMatrix) {
      n.sort((a, b) => a.createDate.compareTo(b.createDate));
      index++;
    }
  }
  return jegyMatrix;
}

List<dynamic> sortByDateAndSubject(List<dynamic> input) {
  input.sort((a, b) => a.subject.compareTo(b.subject));
  int _currentIndex = 0;
  List<Evals> _output = [];
  if (input != null) {
    if (input.length != 0) {
      String _beforeSubject = input[0].subject;
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
    }
  }
  return _output;
}