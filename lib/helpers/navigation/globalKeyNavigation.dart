import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/misc/waitWhile.dart';
import 'package:novynaplo/main.dart';

Future<void> globalWaitAndPushNamed(String tag) async {
  if (globals.isNavigatorLoaded &&
      NavigatorKey.navigatorKey.currentState != null) {
    NavigatorKey.navigatorKey.currentState.pushNamed(tag);
  } else {
    await waitUntil(() => globals.isNavigatorLoaded);
    print("LOADED");
    await delay(500);
    NavigatorKey.navigatorKey.currentState.pushNamed(tag);
  }
  await delay(500);
}

Future<void> globalWaitAndPush(Route route) async {
  if (globals.isNavigatorLoaded &&
      NavigatorKey.navigatorKey.currentState != null) {
    NavigatorKey.navigatorKey.currentState.push(route);
  } else {
    await waitUntil(() => globals.isNavigatorLoaded);
    print("LOADED");
    await delay(500);
    NavigatorKey.navigatorKey.currentState.push(route);
  }
  await delay(500);
}
