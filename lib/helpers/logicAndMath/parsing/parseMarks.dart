import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/database/insertSql.dart';
import 'package:novynaplo/data/models/evals.dart';

Future<List<dynamic>> parseAllByDate(var input) async {
  List<Evals> jegyArray = [];
  var jegyek;
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    for (var n in jegyek) {
      jegyArray.add(Evals.fromJson(n));
    }
  } catch (e, s) {
    FirebaseCrashlytics.instance.recordError(
      e,
      s,
      reason: 'parseAllByDate',
      printDetails: true,
    );
    return [];
  }
  jegyArray.sort((a, b) => b.createDateString.compareTo(a.createDateString));
  await batchInsertEval(jegyArray);
  return jegyArray;
}

List<List<Evals>> categorizeSubjectsFromEvals(List<Evals> input) {
  List<Evals> jegyArray = input;
  List<List<Evals>> jegyMatrix = [[]];
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
  // ignore: unused_local_variable
  int _index = 0;
  for (var n in jegyMatrix) {
    n.sort((a, b) => a.createDate.compareTo(b.createDate));
    _index++;
  }
  return jegyMatrix;
}

List<List<Evals>> sortByDateAndSubject(List<Evals> input) {
  input.sort((a, b) => a.subject.compareTo(b.subject));
  int _currentIndex = 0;
  List<List<Evals>> _tempArray = [[]];
  if (input != null && input.length != 0) {
    String _beforeSubject = input[0].subject;
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
    }
  }
  return _tempArray;
}
