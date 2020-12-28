import 'package:novynaplo/data/database/deleteSql.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;

Future<List<List<Lesson>>> makeTimetableMatrix(List<Lesson> lessons) async {
  if (lessons == null || lessons.length == 0) return [];
  //Variables
  int index = 0;
  List<List<Lesson>> output = [[]];
  DateTime tempDate;
  //Find this monday and sunday
  //FIXME We handled sql deletions here, didn't we?
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

    if (timetablePage.fetchedDayList
            .where((element) => element.isSameDay(n.date))
            .length ==
        0) {
      timetablePage.fetchedDayList.add(n.date);
    }
    timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    //FIXME: Handle sql deletions
  }
  return output;
}
