import 'dart:math';

import 'package:english_words/english_words.dart';
// ignore: implementation_imports
import 'package:flutter/material.dart';
//Loading widget:
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'dart:async';

import 'package:diacritic/diacritic.dart';

import 'package:novynaplo/screens/login_page.dart' as login;

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

List<MaterialColor> getRandomColors(int amount) {
  return List<MaterialColor>.generate(amount, (index) {
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
  return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}

String capitalizePair(WordPair pair) {
  return '${capitalize(pair.first)} ${capitalize(pair.second)}';
}

class MyDialog extends StatefulWidget {
  @override
  MyDialogState createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  String loadingText = login.loadingText;
  final GlobalKey<State> key = login.keyLoader;
  @override
  Widget build(BuildContext context) {
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

  callback(input) {
    setState(() {
      loadingText = input;
    });
  }
}

Future sleep1() async {
  return new Future.delayed(const Duration(seconds: 1), () => "1");
}

String toEnglish(var input) {
  return removeDiacritics(input.toString());
}
