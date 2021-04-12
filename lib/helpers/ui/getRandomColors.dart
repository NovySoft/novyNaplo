import 'dart:math';

import 'package:flutter/material.dart';

const myListOfRandomColors = [
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
    return myListOfRandomColors[_random.nextInt(myListOfRandomColors.length)];
  });
}
