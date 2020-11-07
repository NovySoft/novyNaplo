import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/avarage.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/helpers/functions/capitalize.dart';
import 'package:novynaplo/helpers/themeHelper.dart';
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/screens/marks_tab.dart' as marks;
import 'package:novynaplo/translations/translationProvider.dart';

const _myListOfRandomColors = [
  Colors.red,
  Colors.blue,
  Colors.teal,
  Colors.yellow,
  Colors.amber,
  Colors.deepOrange,
  Colors.green,
  Colors.indigo,
  Colors.lime,
  Colors.pink,
  Colors.orange,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.cyan,
  Colors.purple,
  Colors.deepPurple,
  Colors.amberAccent,
  Colors.limeAccent,
  Colors.tealAccent
];

final _random = Random();

List<Color> getRandomColors(int amount) {
  if (amount == null) amount = 10;
  return List<Color>.generate(amount, (index) {
    return _myListOfRandomColors[_random.nextInt(_myListOfRandomColors.length)];
    //return _myListOfRandomColors[2];
  });
}

class SpinnerDialog extends StatefulWidget {
  @override
  SpinnerDialogState createState() => new SpinnerDialogState();
}

class SpinnerDialogState extends State<SpinnerDialog> {
  String loadingText = getTranslatedString("plsWait");
  static final GlobalKey<State> key = login.KeyLoaderKey.keyLoader;
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return new WillPopScope(
      onWillPop: () async => false,
      child: SimpleDialog(
        key: key,
        backgroundColor: Colors.black54,
        children: <Widget>[
          Center(
            child: Column(
              children: [
                SpinKitPouringHourglass(color: Colors.lightBlueAccent),
                SizedBox(height: 10),
                Text(
                  loadingText,
                  style: TextStyle(color: Colors.blueAccent),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future sleep(int millis) async {
  return new Future.delayed(Duration(milliseconds: millis), () => "1");
}

String parseIntToWeekdayString(int input) {
  switch (input) {
    case 1:
      return "Hétfő";
      break;
    case 2:
      return "Kedd";
      break;
    case 3:
      return "Szerda";
      break;
    case 4:
      return "Csütörtök";
      break;
    case 5:
      return "Péntek";
      break;
    case 6:
      return "Szombat";
      break;
    case 7:
      return "Vasárnap";
      break;
  }
  return null;
}

List<Evals> getSameSubjectEvals(
    {@required String subject, bool sort = false, DateTime onlyBefore}) {
  List<Evals> _tempList = [];
  if (subject == getTranslatedString("contracted")) {
    List<List<Evals>> itteratorList =
        List.from(stats.allParsedSubjectsWithoutZeros);
    for (var n in itteratorList) {
      for (var j in n) {
        _tempList.add(j);
      }
    }
    _tempList.sort((a, b) => a.createDate.compareTo(b.createDate));
    return _tempList;
  }
  _tempList = List.from(stats.allParsedSubjects.firstWhere(
      (element) => element[0].subject.toLowerCase() == subject.toLowerCase()));
  if (onlyBefore != null) {
    _tempList
        .removeWhere((element) => element.createDate.compareTo(onlyBefore) > 0);
  }
  if (sort) {
    _tempList.sort((a, b) => b.createDate.compareTo(a.createDate));
  }
  return List.from(_tempList);
}

int calcPercentFromEvalsList({@required List<Evals> evalList}) {
  List<int> tempList = List.from(
    List.from(evalList).map((element) {
      //Felesleges, mert nem nezunk szazalekokat
      //De azert itt hagyom, hatha ezen valtoztatni fogunk
      if (element.form != "Percent") {
        switch (element.numberValue) {
          case 5:
            return 100;
            break;
          case 4:
            return 75;
            break;
          case 3:
            return 50;
            break;
          case 2:
            return 25;
            break;
          case 1:
            return 0;
            break;
        }
      } else {
        return element.numberValue.toInt();
      }
    }),
  );
  tempList.removeWhere((element) => element == null);
  if (tempList.length == 0) return 0;
  double av = tempList.map((m) => m).reduce((a, b) => a + b) / tempList.length;
  return av.toInt();
}

Color getMarkCardColor({@required Evals eval, @required int index}) {
  Color color;
  if (globals.markCardTheme == "Véletlenszerű") {
    color = marks.colors[index].shade400;
  } else if (globals.markCardTheme == "Értékelés nagysága") {
    if (eval.form == "Percent") {
      if (eval.numberValue >= 90) {
        color = Colors.green;
      } else if (eval.numberValue >= 75) {
        color = Colors.lightGreen;
      } else if (eval.numberValue >= 60) {
        color = Colors.yellow[800];
      } else if (eval.numberValue >= 40) {
        color = Colors.deepOrange;
      } else {
        color = Colors.red[900];
      }
    } else {
      switch (eval.numberValue) {
        case 5:
          color = Colors.green;
          break;
        case 4:
          color = Colors.lightGreen;
          break;
        case 3:
          color = Colors.yellow[800];
          break;
        case 2:
          color = Colors.deepOrange;
          break;
        case 1:
          color = Colors.red[900];
          break;
        default:
          color = Colors.purple;
          break;
      }
    }
  } else if (globals.markCardTheme == "Egyszínű") {
    color = ThemeHelper().stringToColor(globals.markCardConstColor);
  } else if (globals.markCardTheme == "Színátmenetes") {
    color = ThemeHelper().myGradientList[
        (ThemeHelper().myGradientList.length - index - 1).abs()];
  } else {
    color = Colors.red;
  }
  return color;
}

String getMarkCardSubtitle({@required Evals eval, int trimLength = 30}) {
  String subtitle = "undefined";
  if (globals.markCardSubtitle == "Téma") {
    if (eval.theme != null && eval.theme != "")
      subtitle = capitalize(eval.theme);
    else
      subtitle = getTranslatedString("unkown");
  } else if (globals.markCardSubtitle == "Tanár") {
    subtitle = eval.teacher;
  } else if (globals.markCardSubtitle == "Súly") {
    subtitle = eval.weight;
  } else if (globals.markCardSubtitle == "Pontos Dátum") {
    subtitle = eval.createDateString;
  } else if (globals.markCardSubtitle == "Egyszerűsített Dátum") {
    String year = eval.createDate.year.toString();
    String month = eval.createDate.month.toString();
    String day = eval.createDate.day.toString();
    String hour = eval.createDate.hour.toString();
    String minutes = eval.createDate.minute.toString();
    String seconds = eval.createDate.second.toString();
    subtitle = "$year-$month-$day $hour:$minutes:$seconds";
  }
  if (subtitle == "" || subtitle == null) {
    subtitle = getTranslatedString("unkown");
  }
  if (subtitle.length >= trimLength) {
    subtitle = subtitle.substring(0, trimLength - 3);
    subtitle += "...";
  }
  return subtitle;
}

String getTimetableSubtitle(Lesson input) {
  String subtitle = "undefined";
  if (globals.lessonCardSubtitle == "Tanterem") {
    subtitle = input.classroom;
  } else if (globals.lessonCardSubtitle == "Óra témája") {
    subtitle = input.theme;
  } else if (globals.lessonCardSubtitle == "Tanár") {
    if (input.teacher != null || input.teacher != "") {
      subtitle = input.teacher;
    } else {
      subtitle = input.deputyTeacherName;
    }
  } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
    String startMinutes;
    if (input.startDate.minute.toString().startsWith("0")) {
      startMinutes = input.startDate.minute.toString() + "0";
    } else {
      startMinutes = input.startDate.minute.toString();
    }
    String endMinutes;
    if (input.endDate.minute.toString().startsWith("0")) {
      endMinutes = input.endDate.minute.toString() + "0";
    } else {
      endMinutes = input.endDate.minute.toString();
    }
    String start = input.startDate.hour.toString() + ":" + startMinutes;
    String end = input.endDate.hour.toString() + ":" + endMinutes;
    subtitle = "$start-$end";
  } else if (globals.lessonCardSubtitle == "Időtartam") {
    String diff =
        input.endDate.difference(input.startDate).inMinutes.toString();
    subtitle = "$diff ${getTranslatedString("min")}";
  }
  if (subtitle == "" || subtitle == null) {
    subtitle = getTranslatedString("unkown");
  }
  if (subtitle.length >= 28) {
    subtitle = subtitle.substring(0, 25);
    subtitle += "...";
  }
  return subtitle;
}

List<Avarage> createAvarageDBListFromStatisticsAvarage(
  stats.AV bestSubject,
  List<stats.AV> avaragesList,
  stats.AV worstSubject,
) {
  List<Avarage> tempList = [];
  tempList.add(stats.bestSubjectAv.toDatabaseAvarage());
  for (var n in avaragesList) {
    tempList.add(n.toDatabaseAvarage());
  }
  tempList.add(worstSubject.toDatabaseAvarage());
  return tempList;
}

String intToTHEnding(int input) {
  String number = input.toString();
  if (globals.language == "hu") return number + ".";
  if (number.endsWith("1")) {
    return number + "st";
  }
  if (number.endsWith("2")) {
    return number + "nd";
  }
  if (number.endsWith("3")) {
    return number + "rd";
  }
  return number + "th";
}

Color getAbsenceCardColor(Absence absence) {
  Color color = Colors.purple;
  if (absence.justificationState == "BeJustified") {
    color = Colors.yellow;
  } else if (absence.justificationState == "UnJustified") {
    color = Colors.red;
  } else if (absence.justificationState == "Justified") {
    color = Colors.green;
  }
  return color;
}
