import 'package:novynaplo/data/database/insertSql.dart';
import 'package:novynaplo/data/models/avarage.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/logicAndMath/createAvarageDBListFromStatisticsAvarage.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

//Legjobb, legroszabb és a köztes jegyek
//Should change to a return function, shouldn't I?
void getMarksWithChanges(List<List<Evals>> input) async {
  List<AV> tempList = [];
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
    AV temp = new AV();
    for (var y in n) {
      sum += y.szamErtek * y.sulySzazalekErteke / 100;
      index += 1 * y.sulySzazalekErteke / 100;
      if (listIndex == n.length - 1) {
        temp.diffSinceLast = sum / index;
      }
      listIndex++;
    }
    temp.value = sum / index;
    temp.count = index.toDouble();
    temp.subject = n[0].tantargy.nev;
    temp.diffSinceLast = (temp.diffSinceLast - (sum / index)) * -1;
    tempList.add(temp);
  }
  tempList.sort((a, b) =>
      b.value.toStringAsFixed(3).compareTo(a.value.toStringAsFixed(3)));
  index = 0;
  List<AV> tempListTwo = [];
  tempList.removeWhere((item) =>
      item.value == double.nan || item.value.isNaN || item.value == null);
  double curValue = tempList[0].value;
  stats.worstSubjectAv = tempList.last;
  stats.allSubjectsAv = tempList;
  if (tempList.length > 1) {
    //Find the better subject based on count
    while (curValue == tempList[index.toInt()].value) {
      tempListTwo.add(tempList[index.toInt()]);
      index++;
      if (index.toInt() <= tempList.length) {
        curValue = -1;
      }
    }
  } else {
    tempListTwo.add(tempList[0]);
  }
  tempListTwo.sort((a, b) => b.count.compareTo(a.count));
  stats.allSubjectsAv.removeLast();
  stats.allSubjectsAv.removeWhere((item) => item == tempListTwo[0]);
  stats.bestSubjectAv = tempListTwo[0];
  //We dont await it, cause this function is time critical
  batchInsertAvarage(createAvarageDBListFromStatisticsAvarage(
      stats.bestSubjectAv, stats.allSubjectsAv, stats.worstSubjectAv));
}
