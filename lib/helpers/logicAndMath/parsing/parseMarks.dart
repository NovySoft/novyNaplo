import 'package:novynaplo/data/models/evals.dart';

List<List<Evals>> categorizeSubjectsFromEvals(List<Evals> input) {
  List<Evals> jegyArray = List.from(input);
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
