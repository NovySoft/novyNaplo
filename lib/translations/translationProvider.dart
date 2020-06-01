import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/hungarian.dart' as hu;
import 'package:novynaplo/translations/english.dart' as en;
import 'dart:io' show Platform;

String getTranslatedString(String input) {
  //Dont delete this piece of code, it makes sure that the translation is right
  /*String languageCode = Platform.localeName.split('_')[1];
  if (languageCode.toLowerCase().contains('hu')) {
    globals.language = "hu";
  } else {
    globals.language = "en";
  }*/
  if (globals.language == "hu") {
    if (hu.translation[input] != null) return hu.translation[input];
  } else if (globals.language == "en") {
    if (en.translation[input] != null) return en.translation[input];
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
