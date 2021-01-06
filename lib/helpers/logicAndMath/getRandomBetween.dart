import 'dart:math';

int getRandomIntBetween(int min, int max) {
  final _random = new Random();
  return min + _random.nextInt(max - min);
}
