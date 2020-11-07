import 'package:novynaplo/helpers/misc/capitalize.dart';

class SubjectAssignHelper {
  static String assignSubject(dJson, subjectUid, type, content) {
    String finalSubject = "";
    if (type == "Házi feladat hiány" || type == "Felszereléshiány") {
      finalSubject = capitalize(content.split(" ")[0]);
    } else {
      var groups = dJson["OsztalyCsoportok"];
      for (var n in groups) {
        var currentId = n["Uid"];
        if (currentId == subjectUid) {
          finalSubject = n["Nev"];
          break;
        }
      }
    }
    return finalSubject;
  }
}
