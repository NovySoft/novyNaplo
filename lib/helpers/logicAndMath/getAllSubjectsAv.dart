import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

//Összesített átlag
void getAllSubjectsAv(input) {
  double index = 0, sum = 0, tempIndex = 0;
  double tempValue = 0;
  stats.osszesitettAv.count = 0;
  for (var n in input) {
    tempIndex = 0;
    for (var y in n) {
      tempIndex++;
      sum += y.szamErtek * y.sulySzazalekErteke / 100;
      index += 1 * y.sulySzazalekErteke / 100;
      stats.osszesitettAv.value = sum / index;
      if (tempIndex == n.length - 1) {
        tempValue = sum / index;
      }
    }
  }
  stats.osszesitettAv.count = index;
  stats.osszesitettAv.diffSinceLast = (tempValue - (sum / index)) * -1;
}
