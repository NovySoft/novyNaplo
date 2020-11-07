import 'package:novynaplo/translations/translationProvider.dart';

String parseIntToWeekdayString(int input) {
  switch (input) {
    case 1:
      return getTranslatedString("monday");
      break;
    case 2:
      return getTranslatedString("tuesday");
      break;
    case 3:
      return getTranslatedString("wednesday");
      break;
    case 4:
      return getTranslatedString("thursday");
      break;
    case 5:
      return getTranslatedString("friday");
      break;
    case 6:
      return getTranslatedString("saturday");
      break;
    case 7:
      return getTranslatedString("sunday");
      break;
  }
  return null;
}
