import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

List<Evals> getSameSubjectEvals(
    {@required String subject, bool sort = false, DateTime onlyBefore}) {
  List<Evals> _tempList = [];
  if (subject == getTranslatedString("contracted")) {
    List<List<Evals>> itteratorList =
        List.from(stats.allParsedSubjectsWithoutZeros);
    for (var n in itteratorList) {
      for (var j in n) {
        _tempList.add(j);
      }
    }
    _tempList.sort((a, b) => a.createDate.compareTo(b.createDate));
    return _tempList;
  }
  _tempList = List.from(stats.allParsedSubjects.firstWhere(
      (element) => element[0].subject.toLowerCase() == subject.toLowerCase()));
  if (onlyBefore != null) {
    _tempList
        .removeWhere((element) => element.createDate.compareTo(onlyBefore) > 0);
  }
  if (sort) {
    _tempList.sort((a, b) => b.createDate.compareTo(a.createDate));
  }
  return List.from(_tempList);
}
