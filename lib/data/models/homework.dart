import 'osztalyCsoport.dart';
import 'tantargy.dart';

class Homework {
  List<Csatolmanyok> csatolmanyok;
  String feladasDatumaString;
  DateTime feladasDatuma;
  String hataridoDatumaString;
  DateTime hataridoDatuma;
  String rogzitesIdopontjaString;
  DateTime rogzitesIdopontja;
  bool isTanarRogzitette;
  bool isTanuloHaziFeladatEnabled;
  bool isMegoldva;
  String tanar;
  String szoveg;
  Tantargy tantargy;
  OsztalyCsoport osztalyCsoport;
  String uid;
  int id;

  Homework(
      {this.csatolmanyok,
      this.feladasDatuma,
      this.hataridoDatuma,
      this.rogzitesIdopontja,
      this.isTanarRogzitette,
      this.isTanuloHaziFeladatEnabled,
      this.isMegoldva,
      this.tanar,
      this.szoveg,
      this.tantargy,
      this.osztalyCsoport,
      this.uid});

  Homework.fromJson(Map<String, dynamic> json) {
    if (json['Csatolmanyok'] != null) {
      csatolmanyok = new List<Csatolmanyok>();
      json['Csatolmanyok'].forEach((v) {
        csatolmanyok.add(new Csatolmanyok.fromJson(v));
      });
    }
    feladasDatumaString = json['FeladasDatuma'];
    feladasDatuma = feladasDatumaString != null
        ? DateTime.parse(feladasDatumaString)
        : DateTime(2020);
    hataridoDatumaString = json['HataridoDatuma'];
    hataridoDatuma = hataridoDatumaString != null
        ? DateTime.parse(hataridoDatumaString)
        : DateTime(2020);
    rogzitesIdopontjaString = json['RogzitesIdopontja'];
    rogzitesIdopontja = rogzitesIdopontjaString != null
        ? DateTime.parse(rogzitesIdopontjaString)
        : DateTime(2020);
    isTanarRogzitette = json['IsTanarRogzitette'];
    isTanuloHaziFeladatEnabled = json['IsTanuloHaziFeladatEnabled'];
    isMegoldva = json['IsMegoldva'];
    tanar = json['RogzitoTanarNeve'];
    szoveg = json['Szoveg'];
    tantargy = json['Tantargy'] != null
        ? new Tantargy.fromJson(json['Tantargy'])
        : null;
    osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
  }
}

class Csatolmanyok {
  String uid;
  String nev;
  String tipus;

  Csatolmanyok({this.uid, this.nev, this.tipus});

  Csatolmanyok.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    nev = json['Nev'];
    tipus = json['Tipus'];
  }
}
