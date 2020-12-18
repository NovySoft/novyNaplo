import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/calculator.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/calculator_tab.dart' as calculatorPage;

void setUpCalculatorPage(List<List<Evals>> input) {
  FirebaseCrashlytics.instance.log("setUpCalculatorPage");
  calculatorPage.dropdownValues = [];
  calculatorPage.dropdownValue = "";
  calculatorPage.averageList = [];
  if (input != null && input != [[]]) {
    double sum, index;
    for (var n in input) {
      calculatorPage.dropdownValues.add(capitalize(n[0].subject.name));
      sum = 0;
      index = 0;
      for (var y in n) {
        sum += y.numberValue * y.weight / 100;
        index += 1 * y.weight / 100;
      }
      CalculatorData temp = new CalculatorData();
      temp.count = index;
      temp.sum = sum;
      calculatorPage.averageList.add(temp);
    }
  }
  if (calculatorPage.dropdownValues.length != 0)
    calculatorPage.dropdownValue = calculatorPage.dropdownValues[0];
  else
    calculatorPage.dropdownValue = getTranslatedString("possibleNoMarks");
}
