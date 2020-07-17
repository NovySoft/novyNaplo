import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/hungarian.dart' as hu;
import 'package:novynaplo/translations/english.dart' as en;

//TODO remake with variable replacement
String getTranslatedString(String input, {List<String> replaceVariables}) {
  if (globals.language == "hu") {
    if (hu.translation[input] != null) return hu.translation[input];
  } else if (globals.language == "en") {
    if (en.translation[input] != null) return en.translation[input];
  }
  print("Can't translate: $input, lang: ${globals.language}");
  FirebaseAnalytics().logEvent(
    name: "UnkownTranslation",
    parameters: {
      "language": globals.language,
      "stringToTranslate": input,
    },
  );
  return input;
}
