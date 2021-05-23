import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

List<List<Evals>> categorizeSubjectsFromEvals(List<Evals> input) {
  if (input == null) {
    return [];
  }
  List<Evals> jegyArray = List.from(input);
  List<List<Evals>> jegyMatrix = [];
  jegyArray.sort((a, b) => a.subject.fullName.compareTo(b.subject.fullName));
  String lastString = "";
  for (var n in jegyArray) {
    if (n.subject.fullName != lastString) {
      jegyMatrix.add([]);
      lastString = n.subject.fullName;
    }
    jegyMatrix.last.add(n);
  }
  //Calc avarage where there is only percentage and text av-s
  //?This usually applies to first graders
  List<List<Evals>> outputList = [];
  for (var n in jegyMatrix) {
    n.sort(
      (a, b) {
        if (a.date.isSameDay(b.date)) {
          return a.createDate.compareTo(b.createDate);
        } else {
          return a.date.compareTo(b.date);
        }
      },
    );
    //Get half year marker for stats and reports
    int itemIndex = n.indexWhere(
      (element) => element.type.name == "felevi_jegy_ertekeles",
    );
    if (itemIndex != 0 && itemIndex != -1) {
      stats.halfYearMarkers[n[0].subject.fullName] = itemIndex -
          (n[0].kindOf == "Magatartas" || n[0].kindOf == "Szorgalom"
              ? 0.0
              : 0.5);
    }
    n.removeWhere((element) {
      return !(
          //A félévi jegyek nem számítanak, de a magatartás és szorgalom igen
          !(Evals.nonAvTypes.contains(element.type.name)) ||
              element.kindOf == "Magatartas" ||
              element.kindOf == "Szorgalom");
    });
    bool isSzovegesOnly = n.indexWhere((element) =>
                element.valueType.name != "Szazalekos" &&
                element.valueType.name != "Szoveges" &&
                element.valueType.name != "SzazalekosAtszamolt") ==
            -1
        ? true
        : false;
    if (isSzovegesOnly && n.length > 0) {
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
      tempList.removeWhere((element) =>
          element.valueType.name == "Szoveges" ||
          element.valueType.name == "Szazalekos");
      outputList.add(tempList);
    }
  }
  for (var n in outputList) {
    n.sort(
      (a, b) {
        if (a.date.isSameDay(b.date)) {
          return a.createDate.compareTo(b.createDate);
        } else {
          return a.date.compareTo(b.date);
        }
      },
    );
  }
  outputList.removeWhere((e) => e.length == 0);
  outputList.sort((a, b) => a[0].sortIndex.compareTo(b[0].sortIndex));
  return outputList;
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
    }
  }
  _tempArray.sort((a, b) => a[0].sortIndex.compareTo(b[0].sortIndex));
  return _tempArray;
}
