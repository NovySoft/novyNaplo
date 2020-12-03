import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';

int calcPercentFromEvalsList(
    {@required List<Evals> evalList, @required double av}) {
  return (av / 5 * 100).toInt();
  //TODO: make this function a little bit more normal
}
