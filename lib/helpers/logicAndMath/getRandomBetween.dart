import 'dart:math';

int getRandomIntBetween(int min, int max) {
  Random _random = new Random();
  return min + _random.nextInt(max - min);
}
