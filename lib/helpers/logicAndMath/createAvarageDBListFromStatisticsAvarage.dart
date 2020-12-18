import 'package:novynaplo/data/models/average.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

//Used to save averages (created for statiscs page) to database
List<Average> createAverageDBListFromStatisticsAverage(
  AV bestSubject,
  List<AV> averagesList,
  AV worstSubject,
) {
  List<Average> tempList = [];
  tempList.add(stats.bestSubjectAv.toDatabaseAverage());
  for (var n in averagesList) {
    tempList.add(n.toDatabaseAverage());
  }
  tempList.add(worstSubject.toDatabaseAverage());
  return tempList;
}
