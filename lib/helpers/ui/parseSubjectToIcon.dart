import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

IconData parseSubjectToIcon({@required String subject}) {
  if (subject == null) return Icons.create;
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
      subject.toLowerCase().contains("zene") ||
      subject.toLowerCase().contains("furulya") ||
      subject.toLowerCase().contains("hangszer") ||
      subject.toLowerCase().contains("szolfézs")) {
    return MdiIcons.musicClefTreble;
  }
  if (subject.toLowerCase().contains("testnevelés") ||
      subject.toLowerCase().contains("tesi") ||
      subject.toLowerCase().contains("sport")) {
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
  if (subject.toLowerCase().contains("kémia")) {
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
  if (subject.toLowerCase().contains("természet") ||
      subject.toLowerCase().contains("kkterm")) {
    return MdiIcons.tree;
  }
  if (subject.toLowerCase().contains("digitális") &&
      subject.toLowerCase().contains("kultúra")) {
    return MdiIcons.headLightbulb;
  }
  if (subject.toLowerCase().contains("digitális") &&
      subject.toLowerCase().contains("alkalmazások")) {
    return MdiIcons.devices;
  }
  if (subject.toLowerCase().contains("munkavállaló")) {
    return MdiIcons.accountTie;
  }
  if (subject.toLowerCase().contains("projekt")) {
    return MdiIcons.pencilRuler;
  }
  if (subject.toLowerCase().contains("programozás")) {
    return MdiIcons.codeJson;
  }
  if (subject.toLowerCase().contains("tánc")) {
    return MdiIcons.danceBallroom;
  }
  if (subject.toLowerCase().contains("báb")) {
    return MdiIcons.theater;
  }
  if (subject.toLowerCase().contains("színját") ||
      subject.toLowerCase().contains("dráma")) {
    return MdiIcons.dramaMasks;
  }
  if (subject.toLowerCase().contains("barkács")) {
    return MdiIcons.hammerScrewdriver;
  }
  if (subject.toLowerCase().contains("kommunikáció")) {
    return MdiIcons.accountVoice;
  }
  if (subject.toLowerCase().contains("logika")) {
    return MdiIcons.brain;
  }
  //LogUnknown subject so I can add that later
  FirebaseAnalytics().logEvent(
    name: "UnknownSubject",
    parameters: {"subject": subject},
  );
  return Icons.create;
}
