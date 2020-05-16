import 'dart:core';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'classManager.dart';
import 'utils.dart';

int index = 0;
var sum;
var jegyek;
List<Evals> jegyArray = [];
var stringEvals = [];
var catIndex = 0;

Future<List<dynamic>> parseAllByDate(var input) async {
  jegyArray = [];
  //! TODO fix this duplicate code
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    for (var n in jegyek) {
      jegyArray.add(setEvals(n));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAllByDate');
    return [];
  }
  jegyArray.sort((a, b) => b.createDateString.compareTo(a.createDateString));
  await batchInsertEval(jegyArray);
  return jegyArray;
}

List<dynamic> parseAllBySubject(var input) {
  jegyArray = [];
  //! TODO fix this duplicate code
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    for (var n in jegyek) {
      jegyArray.add(setEvals(n));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAllBySubject');
    return [];
  }
  jegyArray = sortByDateAndSubject(jegyArray);
  return jegyArray;
}

Future<List<Avarage>> parseAvarages(var input) async {
  List<Avarage> atlagArray = [];
  try {
    for (var n in input) {
      atlagArray.add(setAvarage(
          n["Subject"], n["Value"], n["classValue"], n["Difference"]));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAvarages');
    return [];
  }
  await batchInsertAvarage(atlagArray);
  return atlagArray;
}

int countNotices(var input) {
  int count = 0;
  if (input != null && input["Notes"] != null) {
    var notices = input["Notes"];
    count = notices.length;
  }
  return count;
}

Future<List<Notices>> parseNotices(var input) async {
  if (input != null && input["Notes"] != null) {
    List<Notices> noticesArray = [];
    var notices = input["Notes"];
    for (var n in notices) {
      noticesArray.add(setNotices(n));
    }
    await batchInsertNotices(noticesArray);
    return noticesArray;
  } else {
    return [];
  }
}

List<String> parseSubjects(var input) {
  List<String> subjectsArray = [];
  var subjects = input["SubjectAverages"];
  for (var n in subjects) {
    subjectsArray.add(capitalize(n["Subject"]));
  }
  return subjectsArray;
}

//*USED BY STATISTICS
List<dynamic> categorizeSubjects(var input) {
  var parsed = input["Evaluations"];
  List<Evals> jegyArray = [];
  List<List<Evals>> jegyMatrix = [[]];
  if (input != [] && input != null && parsed != null && parsed != []) {
    for (var n in parsed) {
      jegyArray.add(setEvals(n));
    }
    jegyArray.sort((a, b) => a.subject.compareTo(b.subject));
    String lastString = "";
    for (var n in jegyArray) {
      if ((n.form != "Percent" && n.type != "HalfYear") ||
          n.subject == "Magatartas" ||
          n.subject == "Szorgalom") {
        if (n.subject != lastString) {
          jegyMatrix.add([]);
          lastString = n.subject;
        }
        jegyMatrix.last.add(n);
      }
    }
    jegyMatrix.removeAt(0);
    index = 0;
    for (var n in jegyMatrix) {
      n.sort((a, b) => a.createDate.compareTo(b.createDate));
      index++;
    }
  }
  return jegyMatrix;
}

List<dynamic> categorizeSubjectsFromEvals(List<Evals> input) {
  List<Evals> jegyArray = input;
  List<List<Evals>> jegyMatrix = [[]];
  jegyArray.sort((a, b) => a.subject.compareTo(b.subject));
  String lastString = "";
  for (var n in jegyArray) {
    if ((n.form != "Percent" && n.type != "HalfYear") ||
        n.subject == "Magatartas" ||
        n.subject == "Szorgalom") {
      if (n.subject != lastString) {
        jegyMatrix.add([]);
        lastString = n.subject;
      }
      jegyMatrix.last.add(n);
    }
  }
  jegyMatrix.removeAt(0);
  index = 0;
  for (var n in jegyMatrix) {
    n.sort((a, b) => a.createDate.compareTo(b.createDate));
    index++;
  }
  return jegyMatrix;
}

List<dynamic> sortByDateAndSubject(List<dynamic> input) {
  input.sort((a, b) => a.subject.compareTo(b.subject));
  int _currentIndex = 0;
  List<Evals> _output = [];
  if (input != null) {
    if (input.length != 0) {
      String _beforeSubject = input[0].subject;
      List<List<Evals>> _tempArray = [[]];
      for (var n in input) {
        if (n.subject != _beforeSubject) {
          _currentIndex++;
          _tempArray.add([]);
          _beforeSubject = n.subject;
        }
        _tempArray[_currentIndex].add(n);
      }
      for (List<Evals> n in _tempArray) {
        n.sort((a, b) => b.createDateString.compareTo(a.createDateString));
        for (var x in n) {
          _output.add(x);
        }
      }
    }
  }
  return _output;
}

List<List<Lesson>> getWeekLessonsFromLessons(List<Lesson> lessons) {
  if (lessons == null) return [];
  List<Lesson> tempLessonList = lessons;
  List<List<Lesson>> output = [[], [], [], [], [], [], []];
  tempLessonList.sort((a, b) => a.startDate.compareTo(b.startDate));
  index = 0;
  if (tempLessonList != null) {
    if (tempLessonList.length != 0) {
      int beforeDay = tempLessonList[0].startDate.day;
      //Just a matrix
      for (var n in tempLessonList) {
        if (n.startDate.day != beforeDay) {
          index++;
          beforeDay = n.startDate.day;
        }
        output[index].add(n);
      }
    }
  }
  return output;
}

Future<List<Exam>> parseExams(var input) async {
  List<Exam> examArray = [];
  try {
    for (var n in input) {
      Exam temp = new Exam();
      temp.id = n["Id"];
      temp.dateWriteString = n["Datum"];
      temp.dateWrite = DateTime.parse(n["Datum"]);
      temp.dateGivenUpString = n["BejelentesDatuma"];
      temp.dateGivenUp = DateTime.parse(n["BejelentesDatuma"]);
      temp.subject = n["Tantargy"];
      temp.teacher = n["Tanar"];
      temp.nameOfExam = n["SzamonkeresMegnevezese"];
      temp.typeOfExam = n["SzamonkeresModja"];
      temp.groupID = n["OsztalyCsoportUid"];
      examArray.add(temp);
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseExams');
    return [];
  }
  //await batchInsertAvarage(examArray);
  return examArray;
}
