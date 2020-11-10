import 'osztalyCsoport.dart';

class Notice {
  String cim;
  String datumString;
  DateTime datum;
  String keszitesDatumaString;
  DateTime keszitesDatuma;
  String tanar;
  String lattamozasDatumaString;
  DateTime lattamozasDatuma;
  OsztalyCsoport osztalyCsoport;
  String tartalom;
  Tipus tipus;
  String uid;
  int id;

  Notice(
      {this.cim,
      this.datumString,
      this.keszitesDatumaString,
      this.tanar,
      this.lattamozasDatumaString,
      this.osztalyCsoport,
      this.tartalom,
      this.tipus,
      this.uid});

  Notice.fromJson(Map<String, dynamic> json) {
    cim = json['Cim'];
    datumString = json['Datum'];
    keszitesDatumaString = json['KeszitesDatuma'];
    tanar = json['KeszitoTanarNeve'];
    lattamozasDatumaString = json['LattamozasDatuma'];
    osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    tartalom = json['Tartalom'];
    tipus = json['Tipus'] != null ? new Tipus.fromJson(json['Tipus']) : null;
    uid = json['Uid'];
  }
}

class Tipus {
  String uid;
  String leiras;
  String nev;

  Tipus({this.uid, this.leiras, this.nev});

  Tipus.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    leiras = json['Leiras'];
    nev = json['Nev'];
  }
}
