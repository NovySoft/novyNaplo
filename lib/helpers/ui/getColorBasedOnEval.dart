import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';

Color getColorBasedOnEval(Evals eval) {
  Color color = Colors.red;
  if (eval.valueType.name == "Szazalekos") {
    //TODO: Variable percentage limits
    if (eval.numberValue >= 90) {
      color = Colors.green;
    } else if (eval.numberValue >= 75) {
      color = Colors.lightGreen;
    } else if (eval.numberValue >= 60) {
      color = Colors.yellow[800];
    } else if (eval.numberValue >= 40) {
      color = Colors.deepOrange;
    } else {
      color = Colors.red[900];
    }
  } else {
    switch (eval.numberValue.round()) {
      case 5:
        color = Colors.green;
        break;
      case 4:
        color = Colors.lightGreen;
        break;
      case 3:
        color = Colors.yellow[800];
        break;
      case 2:
        color = Colors.deepOrange;
        break;
      case 1:
        color = Colors.red[900];
        break;
      default:
        color = Colors.purple;
        break;
    }
  }
  return color;
}
