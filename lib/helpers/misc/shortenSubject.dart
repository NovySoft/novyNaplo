import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/data/models/subject.dart';

//TODO: Apply the lowercase stuff to colors too...
String shortenSubject(Subject input) {
  String lowerSubject = input.fullName.toLowerCase();
  if (subjectMap.containsKey(input.uid)) {
    //If we have a shorthand subject we can safely return
    return subjectMap[input.uid].name;
  }
  String output = input.fullName;
  if (lowerSubject.contains("kötelező komplex természettudomány")) {
    output = "KKterm";
  }
  if (lowerSubject.contains("komplex természet") &&
      !lowerSubject.contains("kötlező")) {
    output = "Komplex természet";
  }
  if (lowerSubject.contains("informatika") &&
      lowerSubject.contains("távközlés")) {
    if (lowerSubject.contains("it")) {
      output = "IT - Info és távköz";
    } else if (lowerSubject.contains("elektronika")) {
      output = "Elektronika - Info és távköz";
    } else if (lowerSubject.contains("gyakorlat") &&
        lowerSubject.contains("ii")) {
      output = "Info és távköz gyakorlat 2";
    } else if (lowerSubject.contains("gyakorlat")) {
      output = "Info és távköz gyakorlat";
    } else if (lowerSubject.contains("alapok") && lowerSubject.contains("ii")) {
      output = "Info és távköz alapok 2";
    } else if (lowerSubject.contains("alapok")) {
      output = "Info és távköz alapok";
    } else {
      output = "Info és távköz";
    }
  }
  if (input.fullName.length >= 30 &&
      input.fullName.isNotEmpty &&
      output == input.fullName) {
    print("Long boi: " + input.fullName);
    FirebaseAnalytics.instance.logEvent(
      name: "LongSubject",
      parameters: {
        "subject": input.fullName,
      },
    );
  }
  return output;
}
