import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/extensions.dart';

Future<List<List<Absence>>> makeAbsencesMatrix(List<Absence> input) async {
  if (input.length == 0) return [];
  List<List<Absence>> outputList = [[]];
  input.sort(
    (a, b) => (b.lesson.startDate.toHumanString() +
            " " +
            b.lesson.lessonNumber.toString())
        .compareTo(
      a.lesson.startDate.toHumanString() +
          " " +
          a.lesson.lessonNumber.toString(),
    ),
  );
  int index = 0;
  DateTime dateBefore = input[0].lesson.startDate;
  for (var n in input) {
    if (!n.lesson.startDate.isSameDay(dateBefore)) {
      index++;
      outputList.add([]);
      dateBefore = n.lesson.startDate;
    }
    outputList[index].add(n);
  }
  return outputList;
}
