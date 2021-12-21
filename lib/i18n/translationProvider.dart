import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/hungarian.dart' as hu;
import 'package:novynaplo/i18n/english.dart' as en;

//TODO: Add option to translate notices, events, evals, homework and subjects
String getTranslatedString(String input, {List<String> replaceVariables}) {
  String tempString;
  if (replaceVariables == null) replaceVariables = [];
  if (globals.language == "hu") {
    if (hu.translation[input] != null) tempString = hu.translation[input];
  } else if (globals.language == "en") {
    if (en.translation[input] != null) tempString = en.translation[input];
  }
  if (tempString != null) {
    for (var i = 0; i < replaceVariables.length; i++) {
      //?{0} ?{1}
      tempString = tempString.replaceAll("?{$i}", replaceVariables[i]);
    }
    return tempString;
  }
  print("Can't translate: $input, lang: ${globals.language}");
  FirebaseAnalytics.instance.logEvent(
    name: "UnknownTranslation",
    parameters: {
      "language": globals.language,
      "stringToTranslate": input,
    },
  );
  return input;
}
