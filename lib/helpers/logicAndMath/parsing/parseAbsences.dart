import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/extensions.dart';

Future<List<List<Absence>>> makeAbsencesMatrix(List<Absence> input) async {
  if (input.length == 0) return [];
  List<List<Absence>> outputList = [[]];
  input.sort(
    (a, b) =>
        (b.ora.kezdoDatumString + " " + b.ora.oraszam.toString()).compareTo(
      a.ora.kezdoDatumString + " " + a.ora.oraszam.toString(),
    ),
  );
  int index = 0;
  DateTime dateBefore = input[0].ora.kezdoDatum;
  for (var n in input) {
    if (!n.ora.kezdoDatum.isSameDay(dateBefore)) {
      index++;
      outputList.add([]);
      dateBefore = n.ora.kezdoDatum;
    }
    outputList[index].add(n);
  }
  return outputList;
}
