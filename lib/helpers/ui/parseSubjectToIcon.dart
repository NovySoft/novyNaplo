import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_icons/flutter_icons.dart';

IconData parseSubjectToIcon({@required String subject}) {
  if (subject == null) return Icons.create;
  if (subject.toLowerCase().contains("higién")) {
    return MdiIcons.dishwasherAlert;
  }
  if (subject.toLowerCase().contains("gasztroenterológia")) {
    return MdiIcons.stomach;
  }
  if (subject.toLowerCase().contains("anatómia")) {
    return MaterialCommunityIcons.human_male_height_variant;
  }
  if (subject.toLowerCase().contains("kardiológia")) {
    return FontAwesome.heartbeat;
  }
  if (subject.toLowerCase().contains("korrep") ||
      (subject.toLowerCase().contains("verseny") &&
          subject.toLowerCase().contains("felkészítés"))) {
    return Entypo.open_book;
  }
  if (subject.toLowerCase().contains("logopéd")) {
    return MaterialIcons.graphic_eq;
  }
  if (subject.toLowerCase().contains("gazdaság") ||
      subject.toLowerCase().contains("pénzügy")) {
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
    return MdiIcons.humanMaleBoard;
  }
  if (subject.toLowerCase().contains("irodalom") ||
      subject.toLowerCase().contains("irodalm")) {
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
      subject.toLowerCase().contains("testnev") ||
      subject.toLowerCase().contains("tesi") ||
      subject.toLowerCase().contains("sport") ||
      subject.toLowerCase().contains("labdarúgás")) {
    return MdiIcons.soccer;
  }
  if (subject.toLowerCase().contains("vizuális kultúra") ||
      (subject.toLowerCase().contains("rajz") &&
          !subject.toLowerCase().contains("föld"))) {
    return MdiIcons.palette;
  }
  if (subject.toLowerCase().contains("földünk") ||
      subject.toLowerCase().contains("geodézia")) {
    return AntDesign.earth;
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
  if (subject.toLowerCase().contains("történelem") ||
      subject.toLowerCase().contains("töri")) {
    return MdiIcons.history;
  }
  if (subject.toLowerCase().contains("földrajz")) {
    return MdiIcons.mapCheck;
  }
  if (subject.toLowerCase().contains("biológia") ||
      subject.toLowerCase().contains("biosz")) {
    return MdiIcons.dna;
  }
  if (subject.toLowerCase().contains("kémia")) {
    return MdiIcons.beakerCheck;
  }
  if (subject.toLowerCase().contains("fizika")) {
    return MdiIcons.atom;
  }
  if (subject.toLowerCase().contains("mechatronika") ||
      subject.toLowerCase().contains("automatizálás")) {
    return MdiIcons.robotIndustrial;
  }
  if (subject.toLowerCase().contains("elektronika")) {
    return MdiIcons.memory;
  }
  if (subject.toLowerCase().contains("informatika") ||
      subject.toLowerCase().contains("számtech") ||
      subject.toLowerCase().contains("távközlés") ||
      subject.toLowerCase().contains("it alapok") ||
      subject.contains("IT")) {
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
  if (subject.toLowerCase().contains("osztályfő") ||
      subject.toLowerCase().contains("ofő")) {
    return MdiIcons.accountVoice;
  }
  if (subject.toLowerCase().contains("művészettörténet")) {
    return MdiIcons.googleEarth;
  }
  if (subject.toLowerCase().contains("napközi")) {
    return MdiIcons.basketball;
  }
  if (subject.toLowerCase().contains("környezetvédelem")) {
    return MdiIcons.nature;
  }
  if (subject.toLowerCase().contains("környezet") ||
      subject.toLowerCase().contains("természet") ||
      subject.toLowerCase().contains("komplex") ||
      subject.toLowerCase().contains("kkterm") ||
      subject.toLowerCase().contains("faipar")) {
    return MdiIcons.tree;
  }
  if (subject.toLowerCase().contains("digitális") &&
      subject.toLowerCase().contains("kultúra")) {
    return MdiIcons.headLightbulb;
  }
  if (subject.toLowerCase().contains("digitális") &&
      subject.toLowerCase().contains("alkalmazás")) {
    return MdiIcons.devices;
  }
  if (subject.toLowerCase().contains("munkavállaló")) {
    return MdiIcons.accountTie;
  }
  if (subject.toLowerCase().contains("projekt") ||
      subject.toLowerCase().contains("tervezés")) {
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
  if (subject.toLowerCase().contains("biblia") ||
      subject.toLowerCase().contains("keresztény")) {
    return MdiIcons.bookCross;
  }
  if (subject.toLowerCase().contains("szerver")) {
    return MdiIcons.server;
  }
  if (subject.toLowerCase().contains("hálózat")) {
    return MdiIcons.lanPending;
  }
  if (subject.toLowerCase().contains("iroda") &&
      (subject.toLowerCase().contains("szoftver") ||
          subject.toLowerCase().contains("alkalmazás"))) {
    return MdiIcons.microsoftPowerpoint;
  }
  if (subject.toLowerCase().contains("gépészet")) {
    return MdiIcons.cogs;
  }
  if (subject.toLowerCase().contains("gépírás")) {
    return MdiIcons.typewriter;
  }
  if (subject.toLowerCase().contains("írás")) {
    return MdiIcons.fountainPenTip;
  }
  if (subject.toLowerCase().contains("forraszt")) {
    return MdiIcons.solderingIron;
  }
  if (subject.toLowerCase().contains("hegeszt")) {
    return MdiIcons.divingScubaTank;
  }
  if (subject.toLowerCase().contains("elektrotechnika")) {
    return Entypo.flow_cascade;
  }
  if (subject.toLowerCase().contains("adó")) {
    return MdiIcons.filePercent;
  }
  if (subject.toLowerCase().contains("rendvédelem") ||
      (subject.toLowerCase().contains("rendvédelmi") &&
          subject.toLowerCase().contains("szerv"))) {
    return MdiIcons.policeBadge;
  }
  if (subject.toLowerCase().contains("vagyonvédelem")) {
    return MdiIcons.shieldHome;
  }
  if (subject.toLowerCase().contains("magánbiztonság") ||
      subject.toLowerCase().contains("önvédelem")) {
    return MdiIcons.karate;
  }
  if (subject.toLowerCase().contains("linux")) {
    return MdiIcons.linux;
  }
  if (subject.toLowerCase().contains("művészetek")) {
    return Entypo.round_brush;
  }
  if (subject.toLowerCase().contains("társadalom") ||
      subject.toLowerCase().contains("szociológ")) {
    return Ionicons.md_people;
  }
  if (subject.toLowerCase().contains("élelmiszerismeret")) {
    return MdiIcons.food;
  }
  if (subject.toLowerCase().contains("élelmiszerbiztonság")) {
    return MdiIcons.foodOff;
  }
  if (subject.toLowerCase().contains("élelmiszerek")) {
    return MdiIcons.foodApple;
  }
  if (subject.toLowerCase().contains("lakatos")) {
    return FontAwesome.key;
  }
  if (subject.toLowerCase().contains("kereskedelem")) {
    return FontAwesome.line_chart;
  }
  if (subject.toLowerCase().contains("műszaki alapismeretek") ||
      (subject.toLowerCase().contains("műszaki") &&
          (subject.toLowerCase().contains("rajz") ||
              subject.toLowerCase().contains("ábr")))) {
    return FontAwesome5Solid.draw_polygon;
  }
  if (subject.toLowerCase().contains("klinikumi gyakorlat")) {
    return FontAwesome5Solid.clinic_medical;
  }
  if (subject.toLowerCase().contains("vagyonőr")) {
    return MdiIcons.pistol;
  }
  if (subject.toLowerCase().contains("erdészet")) {
    return MdiIcons.naturePeople;
  }
  if (subject.toLowerCase().contains("honismeret")) {
    return MdiIcons.bankOutline;
  }
  if (subject.toLowerCase().contains("népism")) {
    return MaterialCommunityIcons.sword_cross;
  }
  if (subject.toLowerCase().contains("munka") ||
      subject.toLowerCase().contains("admin")) {
    return MdiIcons.tie;
  }
  if (subject.toLowerCase().contains("ápolástan")) {
    return MdiIcons.hospital;
  }
  if (subject.toLowerCase().contains("vendéglátás")) {
    return MdiIcons.silverwareClean;
  }
  if (subject.toLowerCase().contains("erőgép") ||
      subject.toLowerCase().contains("agrár")) {
    return FontAwesome5Solid.tractor;
  }
  if (subject.toLowerCase().contains("erőgép")) {
    return FontAwesome5Solid.tractor;
  }
  if (subject.toLowerCase().contains("grafika") ||
      subject.toLowerCase().contains("illusztr")) {
    return MdiIcons.drawing;
  }
  if (subject.toLowerCase().contains("Fotogrammetria")) {
    return MdiIcons.mapSearch;
  }
  if (subject.toLowerCase().contains("termőhely")) {
    return MdiIcons.sprout;
  }
  if (subject.toLowerCase().contains("érettségi")) {
    return MdiIcons.clipboardEdit;
  }
  if (subject.toLowerCase().contains("számvitel") ||
      subject.toLowerCase().contains("könyvelés")) {
    return MdiIcons.calculator;
  }
  if (subject.toLowerCase().contains("hálózatbiztonság")) {
    return MdiIcons.securityNetwork;
  }
  if (subject.toLowerCase().contains("építőipar")) {
    return MdiIcons.crane;
  }
  if (subject.toLowerCase().contains("belgyógyász")) {
    return MdiIcons.stethoscope;
  }
  if (subject.toLowerCase().contains("ruházat")) {
    return MdiIcons.tshirtCrew;
  }
  if (subject.toLowerCase().contains("életvitel")) {
    return MdiIcons.humanHandsup;
  }
  if (subject.toLowerCase().contains("betegmegfigyelés")) {
    return Ionicons.ios_pulse;
  }
  if (subject.toLowerCase().contains("növényismeret")) {
    return MdiIcons.pineTree;
  }
  if (subject.toLowerCase().contains("borbély") ||
      subject.toLowerCase().contains("11707-16")) {
    //11707-16 Fodrász alapműveletek
    return MdiIcons.contentCut;
  }
  if (subject.toLowerCase().contains("11708-16")) {
    //11708-16 Fodrász vegyszeres műveletek
    return MdiIcons.spray;
  }
  if (subject.toLowerCase().contains("fodrász")) {
    return MdiIcons.hairDryer;
  }
  if (subject.toLowerCase().contains("jóga") ||
      subject.toLowerCase().contains("yoga")) {
    return MdiIcons.yoga;
  }
  if (subject.toLowerCase().contains("jog")) {
    return MdiIcons.formatSection;
  }
  if (subject.toLowerCase().contains("erdő")) {
    return Foundation.trees;
  }
  if (subject.toLowerCase().contains("virág")) {
    return MdiIcons.flowerTulip;
  }
  if (subject.toLowerCase().contains("értékesítés")) {
    return MdiIcons.store;
  }
  if (subject.toLowerCase().contains("növénytan")) {
    return MdiIcons.seed;
  }
  if (subject.toLowerCase().contains("közszolgálat")) {
    return MaterialIcons.work;
  }
  if (subject.toLowerCase().contains("egészségügy") &&
      subject.toLowerCase().contains("asszistens")) {
    return MdiIcons.doctor;
  }
  if (subject.toLowerCase().contains("egészségügy")) {
    return MdiIcons.faceMask;
  }
  if (subject.toLowerCase().contains("osztályközösség")) {
    return MdiIcons.accountGroup;
  }
  if (subject.toLowerCase().contains("tanulásmódszertan")) {
    return FontAwesome.map_signs;
  }
  if (subject.toLowerCase().contains("ételkészítés")) {
    return MdiIcons.chefHat;
  }
  if (subject.toLowerCase().contains("raktár")) {
    return MdiIcons.warehouse;
  }
  if (subject.toLowerCase().contains("térkép")) {
    return MdiIcons.mapSearch;
  }
  if (subject.toLowerCase().contains("pénztár")) {
    return MdiIcons.cashRegister;
  }
  if (subject.toLowerCase().contains("közlekedés")) {
    return MaterialIcons.directions_transit;
  }
  if (subject.toLowerCase().contains("építés") ||
      subject.toLowerCase().contains("kőműves")) {
    return MdiIcons.toyBrick;
  }
  if (subject.toLowerCase().contains("diagnosztika")) {
    return MdiIcons.alertCircleCheck;
  }
  if (subject.toLowerCase().contains("falazás") ||
      subject.toLowerCase().contains("vakolás")) {
    return MdiIcons.wall;
  }
  if (subject.toLowerCase().contains("termelés")) {
    return MdiIcons.corn;
  }
  if (subject.toLowerCase().contains("statisztika")) {
    return MdiIcons.chartScatterPlotHexbin;
  }
  if (subject.toLowerCase().contains("cad ")) {
    return MdiIcons.fileCad;
  }
  if (subject.toLowerCase().contains("villamosgép")) {
    return MdiIcons.pump;
  }
  if (subject.toLowerCase().contains("marketing")) {
    return Entypo.megaphone;
  }
  if (subject.toLowerCase().contains("vallás")) {
    return MdiIcons.peace;
  }
  if (subject.toLowerCase().contains("felszolgálás")) {
    return MdiIcons.trayFull;
  }
  if (subject.toLowerCase().contains("vendégfogadás")) {
    return MdiIcons.doorOpen;
  }
  if (subject.toLowerCase().contains("elsősegély")) {
    return FontAwesome5Solid.first_aid;
  }
  if (subject.toLowerCase().contains("turisztika")) {
    return FontAwesome5Solid.route;
  }
  if (subject.toLowerCase().contains("műszaki cikk")) {
    return MdiIcons.laptop;
  }
  if (subject.toLowerCase().contains("kertfenntartás")) {
    return MdiIcons.beeFlower;
  }
  if (subject.toLowerCase().contains("pszichológia")) {
    return MdiIcons.headCog;
  }
  if (subject.toLowerCase().contains("szálloda")) {
    return FontAwesome5Solid.hotel;
  }
  if (subject.toLowerCase().contains("cukrász")) {
    return MdiIcons.cakeLayered;
  }
  if (subject.toLowerCase().contains("rehab")) {
    return MdiIcons.meditation;
  }
  if (subject.toLowerCase().contains("szilárdságtan")) {
    return FontAwesome5Solid.angle_double_down;
  }
  if (subject.toLowerCase().contains("irányítás")) {
    return Entypo.game_controller;
  }
  if (subject.toLowerCase().contains("fémipar") ||
      subject.toLowerCase().contains("kovács")) {
    return MdiIcons.anvil;
  }
  if (subject.toLowerCase().contains("karbantart")) {
    return MdiIcons.wrench;
  }
  if (subject.toLowerCase().contains("gyermek")) {
    return MdiIcons.accountChild;
  }
  if (subject.toLowerCase().contains("személyiség") ||
      subject.toLowerCase().contains("önism")) {
    return MdiIcons.mirror;
  }
  if (subject.toLowerCase().contains("hardver")) {
    return FontAwesome5Solid.microchip;
  }
  if (subject.toLowerCase().contains("filozóf")) {
    return MdiIcons.headQuestion;
  }
  if (subject.toLowerCase().contains("edzés")) {
    return MdiIcons.dumbbell;
  }
  if (subject.toLowerCase().contains("ügyfélszolgálat")) {
    return MdiIcons.helpRhombus;
  }
  if (subject.toLowerCase().contains("gyártás") ||
      subject.toLowerCase().contains("gyártó")) {
    return MdiIcons.factoryIcon;
  }
  if (subject.toLowerCase().contains("dokumentum")) {
    return MdiIcons.fileDocument;
  }
  if (subject.toLowerCase().contains("szerel")) {
    return MdiIcons.screwdriver;
  }
  if (subject.toLowerCase().contains("terápi")) {
    return MaterialIcons.healing;
  }
  if (subject.toLowerCase().contains("kézilabda")) {
    return MdiIcons.handball;
  }
  if (subject.toLowerCase().contains("állat")) {
    return FontAwesome5Solid.dog;
  }
  if (subject.toLowerCase().contains("vadgazd")) {
    return MdiIcons.owl;
  }
  if (subject.toLowerCase().contains("munkavéd") ||
      subject.toLowerCase().contains("munkabizt") ||
      subject.toLowerCase().contains("balesetvédelem")) {
    return MdiIcons.accountHardHat;
  }
  if (subject.toLowerCase().contains("emelőgép") ||
      subject.toLowerCase().contains("targonca") ||
      subject.toLowerCase().contains("szállítógép")) {
    return MdiIcons.forklift;
  }
  if (subject.toLowerCase().contains("plc")) {
    return FontAwesome5Solid.server;
  }
  if (subject.toLowerCase().contains("épületvillamosság")) {
    return MdiIcons.lightningBolt;
  }
  if (subject.toLowerCase().contains("gyógyszer")) {
    return AntDesign.medicinebox;
  }
  if (subject.toLowerCase().contains("akadályozott")) {
    return MdiIcons.humanWheelchair;
  }
  if (subject.toLowerCase().contains("hibavédelem")) {
    return AntDesign.warning;
  }
  if (subject.toLowerCase().contains("alkalmazás") &&
      subject.toLowerCase().contains("fejlesztés")) {
    return FontAwesome5Brands.app_store;
  }
  if (subject.toLowerCase().contains("áramkör")) {
    return Octicons.circuit_board;
  }
  if (subject.toLowerCase().contains("statika")) {
    return AntDesign.arrowdown;
  }
  if (subject.toLowerCase().contains("bútor")) {
    return MdiIcons.sofa;
  }
  if (subject.toLowerCase().contains("divat")) {
    return MdiIcons.dresser;
  }
  if (subject.toLowerCase().contains("katona")) {
    return FontAwesome5Solid.medal;
  }
  if (subject.toLowerCase().contains("levelezés")) {
    return Entypo.email;
  }
  if (subject.toLowerCase().contains("labor")) {
    return Octicons.beaker;
  }
  if (subject.toLowerCase().contains("color")) {
    return Ionicons.md_color_filter;
  }
  if (subject.toLowerCase().contains("pincér")) {
    return MdiIcons.clipboardList;
  }
  if (subject.toLowerCase().contains("burkol")) {
    return MdiIcons.vectorRectangle;
  }
  if (subject.toLowerCase().contains("szakkör")) {
    return FontAwesome5Solid.people_carry;
  }
  if (subject.toLowerCase().contains("gazdálkodás")) {
    return FontAwesome5Solid.money_bill_alt;
  }
  if ((subject.toLowerCase().contains("villamos") ||
          subject.toLowerCase().contains("elektro")) &&
      subject.toLowerCase().contains("mérés")) {
    return MdiIcons.sineWave;
  }
  if ((subject.toLowerCase().contains("villamos") ||
          subject.toLowerCase().contains("elektro")) &&
      subject.toLowerCase().contains("gyakorlat")) {
    return MdiIcons.connection;
  }
  if (subject.toLowerCase().contains("dokumentáció")) {
    return MdiIcons.fileDocumentMultiple;
  }
  if (subject.toLowerCase().contains("kompetencia")) {
    return MdiIcons.headSync;
  }
  if (subject.toLowerCase().contains("tanórán kívül")) {
    return MdiIcons.officeBuildingMarker;
  }
  if (subject.toLowerCase().contains("tehetséggondozás")) {
    return FontAwesome5Solid.hands_helping;
  }
  if (subject.toLowerCase().contains("úszás")) {
    return FontAwesome5Solid.swimmer;
  }
  //LogUnknown subject so I can add that later
  if (subject.isNotEmpty) {
    FirebaseAnalytics.instance.logEvent(
      name: "UnknownSubject",
      parameters: {"subject": subject},
    );
  }
  return Icons.create;
}
