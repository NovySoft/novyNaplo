import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/data/models/evals.dart';

//Összesített átlag
void getAllSubjectsAv(List<List<Evals>> input) {
  double index = 0, sum = 0, tempIndex = 0;
  double tempValue = 0;
  stats.osszesitettAv.count = 0;
  List<Evals> marks = List.from(input).expand((i) => i).toList().cast<Evals>();
  marks.sort((a, b) => a.date.compareTo(b.date));
  for (Evals n in marks) {
    tempIndex++;
    if (!(Evals.nonAvTypes.contains(n.type.name)) ||
        n.kindOf == "Magatartas" ||
        n.kindOf == "Szorgalom") {
      sum += n.numberValue * n.weight / 100;
      index += 1 * n.weight / 100;
      stats.osszesitettAv.value = sum / index;
      if (tempIndex == marks.length - 1) {
        tempValue = sum / index;
      }
    }
  }
  stats.osszesitettAv.count = index;
  stats.osszesitettAv.diffSinceLast = (sum / index) - tempValue;
}
