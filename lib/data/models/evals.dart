import 'package:flutter/material.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:novynaplo/helpers/misc/shortenSubject.dart';
import 'leiras.dart';
import 'osztalyCsoport.dart';
import 'tantargy.dart';

class Evals {
  String tanar;
  Leiras ertekFajta;
  String jelleg;
  String keszitesDatumaString;
  DateTime keszitesDatuma;
  String lattamozasDatumaString;
  DateTime lattamozasDatuma;
  Leiras mod;
  String rogzitesDatumaString;
  DateTime rogzitesDatuma;
  int sulySzazalekErteke;
  int szamErtek;
  String szovegesErtek;
  String szovegesErtekelesRovidNev;
  Tantargy tantargy;
  String tema;
  Leiras tipus;
  OsztalyCsoport osztalyCsoport;
  int sortIndex;
  String uid;
  int id;
  IconData icon;

  Evals(
      {this.tanar,
      this.ertekFajta,
      this.jelleg,
      this.keszitesDatuma,
      this.lattamozasDatuma,
      this.mod,
      this.rogzitesDatuma,
      this.sulySzazalekErteke,
      this.szamErtek,
      this.szovegesErtek,
      this.szovegesErtekelesRovidNev,
      this.tantargy,
      this.tema,
      this.tipus,
      this.osztalyCsoport,
      this.sortIndex,
      this.uid});

  Evals.fromJson(Map<String, dynamic> json) {
    tanar = json['ErtekeloTanarNeve'];
    ertekFajta = json['ErtekFajta'] != null
        ? new Leiras.fromJson(json['ErtekFajta'])
        : null;
    jelleg = json['Jelleg'];
    keszitesDatumaString = json['KeszitesDatuma'];
    keszitesDatuma = keszitesDatumaString != null
        ? DateTime.parse(keszitesDatumaString).toLocal()
        : DateTime(2020);
    lattamozasDatumaString = json['LattamozasDatuma'];
    lattamozasDatuma = lattamozasDatumaString != null
        ? DateTime.parse(lattamozasDatumaString).toLocal()
        : DateTime(2020);
    mod = json['Mod'] != null ? new Leiras.fromJson(json['Mod']) : null;
    rogzitesDatumaString = json['RogzitesDatuma'];
    rogzitesDatuma = rogzitesDatumaString != null
        ? DateTime.parse(rogzitesDatumaString).toLocal()
        : DateTime(2020);
    sulySzazalekErteke = json['SulySzazalekErteke'];
    szamErtek = json['SzamErtek'];
    szovegesErtek = json['SzovegesErtek'];
    szovegesErtekelesRovidNev = json['SzovegesErtekelesRovidNev'];
    tantargy = json['Tantargy'] != null
        ? new Tantargy.fromJson(json['Tantargy'])
        : null;
    tema = json['Tema'];
    tipus = json['Tipus'] != null ? new Leiras.fromJson(json['Tipus']) : null;
    osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    sortIndex = json['SortIndex'];
    uid = json['Uid'];
    if (tema == null) {
      tema = mod.leiras;
    }
    icon = parseSubjectToIcon(subject: tantargy.nev);
  }
}
