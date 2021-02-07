import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;

Future<List<List<Lesson>>> makeTimetableMatrix(
  List<Lesson> lessons, {
  bool addToFetchDayList = true,
}) async {
  if (lessons == null || lessons.length == 0) return [];
  //Variables
  int index = 0;
  List<List<Lesson>> output = [[]];
  DateTime tempDate;

  lessons.sort((a, b) => a.startDate.compareTo(b.startDate));
  tempDate = lessons[0].date;
  for (var n in lessons) {
    if (n.date.isSameDay(tempDate)) {
      output[index].add(n);
    } else {
      tempDate = n.date;
      output.add([]);
      index++;
      output[index].add(n);
    }

    if (addToFetchDayList) {
      if (timetablePage.fetchedDayList
              .where((element) => element.isSameDay(n.date))
              .length ==
          0) {
        timetablePage.fetchedDayList.add(n.date);
      }
      timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    }
  }
  return output;
}
