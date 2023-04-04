import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;

Color getTextColorForBg(Color bgColor) {
  return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

Color getDrawerForeground() {
  if (globals.appBarTextColoredByUser) {
    return globals.currentUser.color;
  } else {
    if (globals.appBarColoredByUser) {
      return getTextColorForBg(globals.currentUser.color);
    }
  }
  return null;
}

Color getTabForeground() {
  if (globals.appBarColoredByUser) {
    return getTextColorForBg(globals.currentUser.color);
  }
  return null;
}
