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
  jegyArray.sort((a, b) => b.rogzitesDatuma.compareTo(a.rogzitesDatuma));
  await batchInsertEval(jegyArray);
  return jegyArray;
}

List<List<Evals>> categorizeSubjectsFromEvals(List<Evals> input) {
  List<Evals> jegyArray = input;
  List<List<Evals>> jegyMatrix = [[]];
  jegyArray.sort((a, b) => a.tantargy.nev.compareTo(b.tantargy.nev));
  String lastString = "";
  for (var n in jegyArray) {
    if ((n.tipus.nev != "Szazalekos" &&
            n.tipus.nev != "felevi_jegy_ertekeles") ||
        n.tantargy.nev == "Magatartas" ||
        n.tantargy.nev == "Szorgalom") {
      if (n.tantargy.nev != lastString) {
        jegyMatrix.add([]);
        lastString = n.tantargy.nev;
      }
      jegyMatrix.last.add(n);
    }
  }
  jegyMatrix.removeAt(0);
  // ignore: unused_local_variable
  int _index = 0;
  for (var n in jegyMatrix) {
    n.sort((a, b) => a.rogzitesDatuma.compareTo(b.rogzitesDatuma));
    _index++;
  }
  print(jegyMatrix);
  return jegyMatrix;
}

List<List<Evals>> sortByDateAndSubject(List<Evals> input) {
  input.sort((a, b) => a.tantargy.nev.compareTo(b.tantargy.nev));
  int _currentIndex = 0;
  List<List<Evals>> _tempArray = [[]];
  if (input != null && input.length != 0) {
    String _beforeSubject = input[0].tantargy.nev;
    for (var n in input) {
      if (n.tantargy.nev != _beforeSubject) {
        _currentIndex++;
        _tempArray.add([]);
        _beforeSubject = n.tantargy.nev;
      }
      _tempArray[_currentIndex].add(n);
    }
    for (List<Evals> n in _tempArray) {
      n.sort((a, b) => b.rogzitesDatuma.compareTo(a.rogzitesDatuma));
    }
  }
  return _tempArray;
}
