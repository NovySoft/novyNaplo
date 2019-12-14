import 'package:novynaplo/functions/utils.dart';

class SubjectAssignHelper {
  String finalSubject = "";

  String assignSubject(dJson, subjectUid, type, content) {
    finalSubject = "";
    if (type == "Házi feladat hiány" || type == "Felszereléshiány") {
      finalSubject = capitalize(content.split(" ")[0]);
    } else {
      var groups = dJson["OsztalyCsoportok"];
      groups.forEach((n) => _compare(n, subjectUid));
    }
    return finalSubject;
  }

  void _compare(element, reqId) {
    var currentId = element["Uid"];
    if (currentId == reqId) {
      finalSubject = element["Nev"];
    }
  }
}
