import 'dart:async';

Future<int> waitUntil(
  bool test(), {
  final int maxIterations = 1000,
  final Duration step = const Duration(milliseconds: 100),
}) async {
  int iterations = 0;
  for (; iterations < maxIterations; iterations++) {
    await Future.delayed(step);
    if (test()) {
      break;
    }
  }
  if (iterations >= maxIterations) {
    throw TimeoutException(
        "Condition not reached within ${iterations * step.inMilliseconds}ms");
  }
  return iterations;
}
