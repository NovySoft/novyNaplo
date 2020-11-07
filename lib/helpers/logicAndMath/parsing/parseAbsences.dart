import 'package:novynaplo/data/database/insertSql.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/extensions.dart';

Future<List<List<Absence>>> parseAllAbsences(input) async {
  List<Absence> tempList = [];
  List<List<Absence>> outputList = [[]];
  var absences = input["Absences"];
  for (var n in absences) {
    tempList.add(new Absence.fromJson(n));
  }
  if (tempList.length == 0) return [];
  tempList.sort(
    (a, b) => (b.lessonStartTimeString + " " + b.numberOfLessons.toString())
        .compareTo(
      a.lessonStartTimeString + " " + a.numberOfLessons.toString(),
    ),
  );
  int index = 0;
  DateTime dateBefore = DateTime.parse(tempList[0].lessonStartTimeString);
  for (var n in tempList) {
    if (!DateTime.parse(n.lessonStartTimeString).isSameDay(dateBefore)) {
      index++;
      outputList.add([]);
      dateBefore = DateTime.parse(n.lessonStartTimeString);
    }
    outputList[index].add(n);
  }
  //Do not await as this a time critical task
  batchInsertAbsences(tempList);
  return outputList;
}
