import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/misc/waitWhile.dart';
import 'package:novynaplo/main.dart';

Future<void> globalWaitAndPushNamed(String tag) async {
  if (globals.isLoaded && NavigatorKey.navigatorKey.currentState != null) {
    NavigatorKey.navigatorKey.currentState.pushNamed(tag);
  } else {
    await waitWhile(() => globals.isLoaded && NavigatorKey.navigatorKey.currentState != null);
    print("LOADED");
    await NavigatorKey.navigatorKey.currentState.pushNamed(tag);
  }
  await delay(100);
}

Future<void> globalWaitAndPush(Route route) async {
  if (globals.isLoaded && NavigatorKey.navigatorKey.currentState != null) {
    NavigatorKey.navigatorKey.currentState.push(route);
  } else {
    waitWhile(() => globals.isLoaded && NavigatorKey.navigatorKey.currentState != null);
    print("LOADED");
    NavigatorKey.navigatorKey.currentState.push(route);
  }
  await delay(100);
}
