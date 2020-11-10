import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';

int calcPercentFromEvalsList({@required List<Evals> evalList}) {
  List<int> tempList = List.from(
    List.from(evalList).map((element) {
      //Felesleges, mert nem nezunk szazalekokat
      //De azert itt hagyom, hatha ezen valtoztatni fogunk
      if (element.form != "Percent") {
        switch (element.szamErtek) {
          case 5:
            return 100;
            break;
          case 4:
            return 75;
            break;
          case 3:
            return 50;
            break;
          case 2:
            return 25;
            break;
          case 1:
            return 0;
            break;
        }
      } else {
        return element.szamErtek.toInt();
      }
    }),
  );
  tempList.removeWhere((element) => element == null);
  if (tempList.length == 0) return 0;
  double av = tempList.map((m) => m).reduce((a, b) => a + b) / tempList.length;
  return av.toInt();
}
