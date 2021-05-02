import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';

List<List<Evals>> categorizeSubjectsFromEvals(List<Evals> input) {
  if (input == null) {
    return [];
  }
  List<Evals> jegyArray = List.from(input);
  List<List<Evals>> jegyMatrix = [];
  jegyArray.sort((a, b) => a.subject.fullName.compareTo(b.subject.fullName));
  String lastString = "";
  for (var n in jegyArray) {
    if ((n.valueType.name != "Szazalekos" &&
            //A félévi jegyek nem számítanak, de a magatartás és szorgalom igen
            !(Evals.nonAvTypes.contains(n.type.name))) ||
        n.kindOf == "Magatartas" ||
        n.kindOf == "Szorgalom") {
      if (n.subject.fullName != lastString) {
        jegyMatrix.add([]);
        lastString = n.subject.fullName;
      }
      jegyMatrix.last.add(n);
    }
  }
  //Calc avarage where there is only percentage and text av-s
  //?This usually applies to first graders
  List<List<Evals>> outputList = [];
  for (var n in jegyMatrix) {
    bool isSzovegesOnly = n.indexWhere((element) =>
                element.valueType.name != "Szazalekos" &&
                element.valueType.name != "Szoveges") ==
            -1
        ? true
        : false;
    if (isSzovegesOnly) {
      List<Evals> listOfSubjectX = jegyArray
          .where((element) =>
              element.subject.fullName.toLowerCase() ==
              n[0].subject.fullName.toLowerCase())
          .toList();
      List<Evals> tempIteratorList = [];
      for (var i = 0; i < listOfSubjectX.length; i++) {
        if (!Evals.nonAvTypes.contains(listOfSubjectX[i].type.name)) {
          if (listOfSubjectX[i].valueType.name == "Szazalekos") {
            //Convert percentage mark to a normal one
            double markValue = (listOfSubjectX[i].numberValue / 100) * 5;
            if (markValue < 1) {
              markValue = 1;
            }
            listOfSubjectX[i].numberValue = markValue;
            listOfSubjectX[i].weight = 100;
            listOfSubjectX[i].valueType.name = "SzazalekosAtszamolt";
          }
          tempIteratorList.add(listOfSubjectX[i]);
        }
      }
      outputList.add(tempIteratorList);
    } else {
      List<Evals> tempList = List.from(n);
      tempList.removeWhere((element) => element.valueType.name == "Szoveges");
      outputList.add(tempList);
    }
  }
  for (var n in outputList) {
    n.sort((a, b) => a.date.compareTo(b.date));
  }
  outputList.sort((a, b) => a[0].sortIndex.compareTo(b[0].sortIndex));
  return outputList;
}

List<List<Evals>> sortByDateAndSubject(List<Evals> inputOne) {
  List<Evals> input = List.from(inputOne);
  input.sort((a, b) => a.subject.fullName.compareTo(b.subject.fullName));
  int _currentIndex = 0;
  List<List<Evals>> _tempArray = [[]];
  if (input != null && input.length != 0) {
    String _beforeSubject = input[0].subject.fullName;
    for (var n in input) {
      if (n.subject.fullName != _beforeSubject) {
        _currentIndex++;
        _tempArray.add([]);
        _beforeSubject = n.subject.fullName;
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
    }
  }
  _tempArray.sort((a, b) => a[0].sortIndex.compareTo(b[0].sortIndex));
  return _tempArray;
}
