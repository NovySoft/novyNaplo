import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';

List<List<Evals>> categorizeSubjectsFromEvals(List<Evals> input) {
  List<Evals> jegyArray = List.from(input);
  List<List<Evals>> jegyMatrix = [[]];
  jegyArray.sort((a, b) => a.subject.name.compareTo(b.subject.name));
  String lastString = "";
  for (var n in jegyArray) {
    if ((n.valueType.name != "Szazalekos" &&
            n.type.name != "felevi_jegy_ertekeles") ||
        n.subject.name == "Magatartas" ||
        n.subject.name == "Szorgalom") {
      if (n.subject.name != lastString) {
        jegyMatrix.add([]);
        lastString = n.subject.name;
      }
      jegyMatrix.last.add(n);
    }
  }
  jegyMatrix.removeAt(0);
  // ignore: unused_local_variable
  int _index = 0;
  for (var n in jegyMatrix) {
    n.sort((a, b) => a.date.compareTo(b.date));
    _index++;
  }
  return jegyMatrix;
}

List<List<Evals>> sortByDateAndSubject(List<Evals> inputOne) {
  List<Evals> input = List.from(inputOne);
  input.sort((a, b) => a.subject.name.compareTo(b.subject.name));
  int _currentIndex = 0;
  List<List<Evals>> _tempArray = [[]];
  if (input != null && input.length != 0) {
    String _beforeSubject = input[0].subject.name;
    for (var n in input) {
      if (n.subject.name != _beforeSubject) {
        _currentIndex++;
        _tempArray.add([]);
        _beforeSubject = n.subject.name;
      }
      _tempArray[_currentIndex].add(n);
    }
    for (List<Evals> n in _tempArray) {
      n.sort(
        (a, b) {
          if (a.date.isSameDay(b.date)) {
            return b.createDate.compareTo(a.createDate);
          } else {
            return b.date.compareTo(a.date);
          }
        },
      );
      ;
    }
  }
  return _tempArray;
}
