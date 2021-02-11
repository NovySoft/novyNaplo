import 'package:firebase_analytics/firebase_analytics.dart';

String shortenSubject(String input) {
  //TODO: Custom röviditések
  if (input.toLowerCase().contains("kötelező komplex természettudomány")) {
    return "KKterm";
  }
  if (input.toLowerCase().contains("komplex természet") &&
      !input.toLowerCase().contains("kötlező")) {
    return "Komplex természet";
  }
  if (input.toLowerCase().contains("informatika") &&
      input.toLowerCase().contains("távközlés")) {
    if (input.toLowerCase().contains("it")) {
      return "Info és távköz - IT";
    }
    if (input.toLowerCase().contains("elektronika")) {
      return "Info és távköz - Elektronika";
    }
    return "Info és távköz";
  }
  if (input.length >= 30 && input.isNotEmpty) {
    FirebaseAnalytics().logEvent(
      name: "LongSubject",
      parameters: {
        "subject": input,
      },
    );
  }
  return input;
}
