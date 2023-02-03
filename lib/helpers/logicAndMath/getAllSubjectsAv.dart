import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import '../../data/models/evals.dart';

//Összesített átlag
void getAllSubjectsAv(List<Evals> input) {
  double index = 0, sum = 0, tempIndex = 0;
  double tempValue = 0;
  stats.osszesitettAv.count = 0;
  for (var n in input) {
    tempIndex++;
    if (!Evals.nonAvTypes.contains(n.type.name)) {
      sum += n.numberValue * n.weight / 100;
      index += 1 * n.weight / 100;
      stats.osszesitettAv.value = sum / index;
      if (tempIndex == input.length - 1) {
        tempValue = sum / index;
      }
    }
  }
  stats.osszesitettAv.count = index;
  stats.osszesitettAv.diffSinceLast = (sum / index) - tempValue;
}
