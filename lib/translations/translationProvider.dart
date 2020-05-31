import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/hungarian.dart' as hu;
import 'package:novynaplo/translations/english.dart' as en;

String getTranslatedString(String input) {
  if (globals.language == "hu") {
    if(hu.translation[input] != null) return hu.translation[input];
  } else if (globals.language == "en") {
    if(en.translation[input] != null) return en.translation[input];
  }
  print("Can't translate: $input");
  FirebaseAnalytics().logEvent(
    name: "UnkownTranslation",
    parameters: {
      "language": globals.language,
      "stringToTranslate": input,
    },
  );
  return input;
}
