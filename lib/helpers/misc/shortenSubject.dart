import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/subject.dart';

Map<String, String> subjectNicknameMap = new Map<String, String>();

//TODO: Teacher nicknames and timetable nicknames
//TODO: Apply the lowercase stuff to colors too...
String shortenSubject(Subject input) {
  String lowerSubject = input.fullName.toLowerCase();
  if (subjectNicknameMap.containsKey(lowerSubject)) {
    //If we have a shorthand subject we can safely return
    return subjectNicknameMap[lowerSubject];
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
    } else {
      output = "Info és távköz";
    }
  }
  if (input.fullName.length >= 30 &&
      input.fullName.isNotEmpty &&
      output == input.fullName) {
    print("Long boi: " + input.fullName);
    FirebaseAnalytics().logEvent(
      name: "LongSubject",
      parameters: {
        "subject": input.fullName,
      },
    );
  }
  subjectNicknameMap[lowerSubject] = output;
  DatabaseHelper.insertSubjNick(
    Subject(
      fullName: lowerSubject,
      name: output,
      category: input.category,
    ),
  );
  return output;
}
