import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

//Legjobb, legroszabb és a köztes jegyek
//TODO: Should change to a return function, shouldn't I?
Future<void> getMarksWithChanges(
  List<List<Evals>> input,
  Student userDetails,
) async {
  List<Average> tempList = [];
  double sum = 0, index = 0;
  int listIndex = 0;
  int nonWeightedCount = 0;
  for (var n in input) {
    index = 0;
    sum = 0;
    if (n.length == 1) {
      listIndex = 0;
    } else {
      listIndex = 1;
    }
    nonWeightedCount = 0;
    Average temp = new Average();
    temp.userId = userDetails.userId;
    for (var y in n) {
      sum += y.numberValue * y.weight / 100;
      index += 1 * y.weight / 100;
      if (listIndex == n.length - 1) {
        temp.diffSinceLast = sum / index;
      }
      listIndex++;
      nonWeightedCount++;
    }
    temp.value = sum / index;
    temp.count = index.toDouble();
    temp.nonWeightedCount = nonWeightedCount;
    temp.subjectName = n[0].subject.name;
    temp.subjectUid = n[0].subject.uid;
    temp.diffSinceLast = (temp.diffSinceLast - (sum / index)) * -1;
    temp.classAverage = stats.classAverages[temp.subjectUid];
    tempList.add(temp);
  }
  //?First sort by the values
  tempList.sort((a, b) => b.value.compareTo(a.value));
  //?Create matrix based on values
  List<List<Average>> tempMatrix = [];
  double lastAv = -1;
  for (var n in tempList) {
    if (lastAv != n.value) {
      lastAv = n.value;
      tempMatrix.add([]);
    }
    tempMatrix.last.add(n);
  }
  for (var i = 0; i < tempMatrix.length; i++) {
    tempMatrix[i].sort(
      (a, b) => b.nonWeightedCount.compareTo(a.nonWeightedCount),
    );
  }
  stats.allSubjectsAv = List.from(tempMatrix.expand((element) => element));
}

Future<void> onlyCalcAndInsertAverages(
  List<List<Evals>> input,
  Student userDetails,
) async {
  List<Average> tempList = [];
  double sum = 0, index = 0;
  int listIndex = 0;
  for (var n in input) {
    index = 0;
    sum = 0;
    if (n.length == 1) {
      listIndex = 0;
    } else {
      listIndex = 1;
    }
    Average temp = new Average();
    temp.userId = userDetails.userId;
    for (var y in n) {
      sum += y.numberValue * y.weight / 100;
      index += 1 * y.weight / 100;
      if (listIndex == n.length - 1) {
        temp.diffSinceLast = sum / index;
      }
      listIndex++;
    }
    temp.value = sum / index;
    temp.count = index.toDouble();
    temp.subjectName = n[0].subject.name;
    temp.subjectUid = n[0].subject.uid;
    temp.diffSinceLast = (temp.diffSinceLast - (sum / index)) * -1;
    temp.classAverage = stats.classAverages[temp.subjectUid];
    tempList.add(temp);
  }
  await DatabaseHelper.batchInsertAverages(tempList, userDetails);
}
