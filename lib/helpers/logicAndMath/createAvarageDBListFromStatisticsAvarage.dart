import 'package:novynaplo/data/models/avarage.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

//Used to save avarages (created for statiscs page) to database
List<Avarage> createAvarageDBListFromStatisticsAvarage(
  stats.AV bestSubject,
  List<stats.AV> avaragesList,
  stats.AV worstSubject,
) {
  List<Avarage> tempList = [];
  tempList.add(stats.bestSubjectAv.toDatabaseAvarage());
  for (var n in avaragesList) {
    tempList.add(n.toDatabaseAvarage());
  }
  tempList.add(worstSubject.toDatabaseAvarage());
  return tempList;
}
