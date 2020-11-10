import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/exam.dart';

Future<List<Exam>> parseExams(var input) async {
  List<Exam> examArray = [];
  try {
    for (var n in input) {
      Exam temp = new Exam.fromJson(n);
      if (!temp.datum.add(Duration(days: 7)).isBefore(DateTime.now())) {
        examArray.add(temp);
      }
    }
  } catch (e, s) {
    FirebaseCrashlytics.instance.recordError(
      e,
      s,
      reason: 'parseExams',
      printDetails: true,
    );
    return [];
  }
  return examArray;
}
