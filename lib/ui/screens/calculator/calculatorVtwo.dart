import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';

/// Calculate the best way to reach a specific av
List<int> jegyszamolo({
  @required List<Evals> jegyekInput, //<-- Input of evals
  @required double kivantAtlag, //<-- Average to reach
  @required double hatar, //<-- Under how many marks
  int pontossag = 1000, //<-- Accuracy, shouldn't be changed
}) {
  hatar *= pontossag;
  List<double> jegyek = [];

  for (var x in jegyekInput) {
    for (var y = 1 / pontossag; y <= (x.weight / 100); y += 1 / pontossag) {
      jegyek.add(x.numberValue);
    }
  }

  double n = jegyek.length + hatar;
  double a = (kivantAtlag * n).ceil().toDouble();

  for (var x in jegyek) {
    a -= x;
  }

  return [
    (a / hatar).floor(),
    ((hatar - (a - (a / hatar).floor() * hatar)) / pontossag).floor(),
    (a / hatar).floor() + 1,
    ((a - (a / hatar).floor() * hatar) / pontossag).ceil(),
  ];
}
