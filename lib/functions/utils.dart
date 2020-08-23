import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
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

//TODO Remove unused stuff
// Avoid customizing the word generator, which can be slow.
// https://github.com/filiph/english_words/issues/9
final wordPairIterator = generateWordPairs();

String generateRandomHeadline() {
  final artist = capitalizePair(wordPairIterator.first);

  switch (_random.nextInt(10)) {
    case 0:
      return '$artist says ${nouns[_random.nextInt(nouns.length)]}';
    case 1:
      return '$artist arrested due to ${wordPairIterator.first.join(' ')}';
    case 2:
      return '$artist releases ${capitalizePair(wordPairIterator.first)}';
    case 3:
      return '$artist talks about his ${nouns[_random.nextInt(nouns.length)]}';
    case 4:
      return '$artist talks about her ${nouns[_random.nextInt(nouns.length)]}';
    case 5:
      return '$artist talks about their ${nouns[_random.nextInt(nouns.length)]}';
    case 6:
      return '$artist says their music is inspired by ${wordPairIterator.first.join(' ')}';
    case 7:
      return '$artist says the world needs more ${nouns[_random.nextInt(nouns.length)]}';
    case 8:
      return '$artist calls their band ${adjectives[_random.nextInt(adjectives.length)]}';
    case 9:
      return '$artist finally ready to talk about ${nouns[_random.nextInt(nouns.length)]}';
  }

  assert(false, 'Failed to generate news headline');
  return null;
}

List<Color> getRandomColors(int amount) {
  if (amount == null) amount = 10;
  return List<Color>.generate(amount, (index) {
    return _myListOfRandomColors[_random.nextInt(_myListOfRandomColors.length)];
    //return _myListOfRandomColors[2];
  });
}

List<String> getRandomNames(int amount) {
  return wordPairIterator
      .take(amount)
      .map((pair) => capitalizePair(pair))
      .toList();
}

String capitalize(String word) {
  if (word == null ||
      word == "" ||
      word.length == 0 ||
      (word is String) == false) {
    return "";
  }
  if (word.length < 2) return word;
  return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}

String capitalizePair(WordPair pair) {
  return '${capitalize(pair.first)} ${capitalize(pair.second)}';
}

class SpinnerDialog extends StatefulWidget {
  @override
  SpinnerDialogState createState() => new SpinnerDialogState();
}

class SpinnerDialogState extends State<SpinnerDialog> {
  String loadingText = getTranslatedString("plsWait");
  final GlobalKey<State> key = login.keyLoader;
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
                child: Column(children: [
                  SpinKitPouringHourglass(color: Colors.lightBlueAccent),
                  SizedBox(height: 10),
                  Text(
                    loadingText,
                    style: TextStyle(color: Colors.blueAccent),
                  )
                ]),
              )
            ]));
  }
}

Future sleep(int millis) async {
  return new Future.delayed(Duration(milliseconds: millis), () => "1");
}

bool isLeap(int year) {
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      if (year % 400 == 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  } else {
    return false;
  }
}

//TODO look into usage and delete if unnecessary
int getMonthLength(int input, bool isLeap) {
  switch (input) {
    case 1:
      return 31;
      break;
    case 2:
      if (isLeap) {
        return 29;
      } else {
        return 28;
      }
      break;
    case 3:
      return 31;
      break;
    case 4:
      return 30;
      break;
    case 5:
      return 31;
      break;
    case 6:
      return 30;
      break;
    case 7:
      return 31;
      break;
    case 8:
      return 31;
      break;
    case 9:
      return 30;
      break;
    case 10:
      return 31;
      break;
    case 11:
      return 30;
      break;
    case 12:
      return 31;
      break;
    default:
      return 0;
  }
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

IconData parseSubjectToIcon({@required String subject}) {
  if (subject.toLowerCase().contains("gazdaság")) {
    return MdiIcons.cashMultiple;
  }
  if ((subject.toLowerCase().contains("etika") ||
      subject.toLowerCase().contains("erkölcs"))) {
    return MdiIcons.headHeart;
  }
  if (subject.toLowerCase().contains("hit")) {
    return MdiIcons.shieldCross;
  }
  if (subject.toLowerCase().contains("magatartas") ||
      subject.toLowerCase().contains("magatartás")) {
    return MdiIcons.handHeart;
  }
  if (subject.toLowerCase().contains("szorgalom")) {
    return MdiIcons.teach;
  }
  if (subject.toLowerCase().contains("irodalom")) {
    return MdiIcons.notebookMultiple;
  }
  if (subject.toLowerCase().contains("nyelvtan") ||
      subject.toLowerCase().contains("magyar nyelv")) {
    return MdiIcons.alphabetical;
  }
  if (subject.toLowerCase().contains("ének") ||
      subject.toLowerCase().contains("zene")) {
    return MdiIcons.musicClefTreble;
  }
  if (subject.toLowerCase().contains("testnevelés") ||
      subject.toLowerCase().contains("tesi")) {
    return MdiIcons.soccer;
  }
  if (subject.toLowerCase().contains("vizuális kultúra") ||
      (subject.toLowerCase().contains("rajz") &&
          !subject.toLowerCase().contains("föld"))) {
    return MdiIcons.palette;
  }
  if ((subject.toLowerCase().contains("német") ||
          subject.toLowerCase().contains("francia") ||
          subject.toLowerCase().contains("idegen") ||
          subject.toLowerCase().contains("nyelv") ||
          subject.toLowerCase().contains("angol") ||
          subject.toLowerCase().contains("héber") ||
          subject.toLowerCase().contains("english")) &&
      !subject.toLowerCase().contains("magyar")) {
    return MdiIcons.translate;
  }
  if (subject.toLowerCase().contains("történelem")) {
    return MdiIcons.history;
  }
  if (subject.toLowerCase().contains("földrajz")) {
    return MdiIcons.mapCheck;
  }
  if (subject.toLowerCase().contains("biológia")) {
    return MdiIcons.dna;
  }
  if (subject.toLowerCase().contains("kémia") ||
      subject.toLowerCase().contains("term. tud.")) {
    return MdiIcons.beakerCheck;
  }
  if (subject.toLowerCase().contains("fizika")) {
    return MdiIcons.atom;
  }
  if (subject.toLowerCase().contains("informatika") ||
      subject.toLowerCase().contains("távközlés")) {
    return MdiIcons.desktopTowerMonitor;
  }
  if (subject.toLowerCase().contains("matek") ||
      subject.toLowerCase().contains("matematika")) {
    return MdiIcons.androidStudio;
  }
  if (subject.toLowerCase().contains("ügyvitel")) {
    return MdiIcons.keyboardSettings;
  }
  if (subject.toLowerCase().contains("mozgógépkultúra") ||
      subject.toLowerCase().contains("mozgóképkultúra") ||
      subject.toLowerCase().contains("média")) {
    return MdiIcons.videoVintage;
  }
  if (subject.toLowerCase().contains("osztályfő")) {
    return MdiIcons.accountVoice;
  }
  if (subject.toLowerCase().contains("művészettörténet")) {
    return MdiIcons.googleEarth;
  }
  if (subject.toLowerCase().contains("napközi")) {
    return MdiIcons.basketball;
  }
  //LogUnkown subject so I can add that later
  FirebaseAnalytics().logEvent(
    name: "UnkownSubject",
    parameters: {"subject": subject},
  );
  return Icons.create;
}

List<Evals> getSameSubjectEvals(
    {@required String subject, bool sort = false, DateTime onlyBefore}) {
  List<Evals> tempList = List.from(stats.allParsedSubjects.firstWhere(
      (element) => element[0].subject.toLowerCase() == subject.toLowerCase()));
  if (onlyBefore != null) {
    tempList
        .removeWhere((element) => element.createDate.compareTo(onlyBefore) > 0);
  }
  if (sort) {
    tempList.sort((a, b) => b.createDate.compareTo(a.createDate));
  }
  return List.from(tempList);
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
