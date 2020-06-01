import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:diacritic/diacritic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/global.dart' as globals;
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

Future sleep1() async {
  return new Future.delayed(const Duration(seconds: 1), () => "1");
}

Future sleep2() async {
  return new Future.delayed(const Duration(milliseconds: 500), () => "500");
}

String toEnglish(var input) {
  return removeDiacritics(input.toString());
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
  if(subject.toLowerCase().contains("művészettörténet")){
    return MdiIcons.googleEarth;
  }
  if(subject.toLowerCase().contains("napközi")){
    return MdiIcons.basketball;
  }
  //LogUnkown subject so I can add that later
  FirebaseAnalytics().logEvent(
    name: "UnkownSubject",
    parameters: {"subject": subject},
  );
  return Icons.create;
}
