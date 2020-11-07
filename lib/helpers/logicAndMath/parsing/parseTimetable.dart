import 'package:novynaplo/data/database/deleteSql.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;

Future<List<List<Lesson>>> makeTimetableMatrix(List<Lesson> lessons) async {
  if (lessons == null) return [];
  //Variables
  int index = 0;
  List<List<Lesson>> output = [[]];
  DateTime tempDate;
  //Find this monday and sunday
  DateTime now = new DateTime.now();
  now = new DateTime(now.year, now.month, now.day);
  int monday = 1;
  int sunday = 7;
  while (now.weekday != monday) {
    now = now.subtract(new Duration(days: 1));
  }
  DateTime startMonday = now;
  now = new DateTime.now();
  now = new DateTime(now.year, now.month, now.day);
  while (now.weekday != sunday) {
    now = now.add(new Duration(days: 1));
  }
  DateTime endSunday = now;
  for (var n in lessons) {
    if (n.date.compareTo(startMonday) >= 0 &&
        n.date.compareTo(endSunday) <= 0) {
      if (tempDate == null) {
        tempDate = n.date;
      }
      if (n.date.isSameDay(tempDate)) {
        output[index].add(n);
      } else {
        tempDate = n.date;
        output.add([]);
        index++;
      }

      if (timetablePage.fetchedDayList
              .where((element) =>
                  element.day == n.date.day &&
                  element.month == n.date.month &&
                  element.year == n.date.year)
              .length ==
          0) {
        timetablePage.fetchedDayList.add(n.date);
      }
      timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    } else {
      timetablePage.fetchedDayList.removeWhere((element) =>
          element.day == n.date.day &&
          element.month == n.date.month &&
          element.year == n.date.year);
      await deleteFromDb(n.databaseId, "Timetable");
    }
  }
  return output;
}
