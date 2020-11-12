import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/leiras.dart';
import 'package:novynaplo/data/models/tantargy.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'homework.dart';
import 'package:novynaplo/global.dart' as globals;

import 'osztalyCsoport.dart';

class Lesson {
  Leiras allapot;
  List<String> bejelentettSzamonkeresUids;
  String bejelentettSzamonkeresUid;
  String datumString;
  DateTime datum;
  String helyettesTanarNeve;
  bool isTanuloHaziFeladatEnabled;
  String kezdetIdopontString;
  DateTime kezdetIdopont;
  String nev;
  int oraszam;
  int oraEvesSorszama;
  OsztalyCsoport osztalyCsoport;
  String haziFeladatUid;
  bool isHaziFeladatMegoldva;
  String tanarNeve;
  Tantargy tantargy;
  Leiras tanuloJelenlet;
  String tema;
  String teremNeve;
  Leiras tipus;
  String uid;
  String vegIdopontString;
  DateTime vegIdopont;
  int databaseId;
  int id;
  IconData icon;

  Lesson(
      {this.allapot,
      this.bejelentettSzamonkeresUids,
      this.bejelentettSzamonkeresUid,
      this.datumString,
      this.helyettesTanarNeve,
      this.isTanuloHaziFeladatEnabled,
      this.kezdetIdopontString,
      this.nev,
      this.oraszam,
      this.oraEvesSorszama,
      this.osztalyCsoport,
      this.haziFeladatUid,
      this.isHaziFeladatMegoldva,
      this.tanarNeve,
      this.tantargy,
      this.tanuloJelenlet,
      this.tema,
      this.teremNeve,
      this.tipus,
      this.uid,
      this.vegIdopontString});

  Lesson.fromJson(Map<String, dynamic> json) {
    //FIXME: Attach homework and exam object if present
    allapot =
        json['Allapot'] != null ? new Leiras.fromJson(json['Allapot']) : null;
    if (json['BejelentettSzamonkeresUids'] != null) {
      bejelentettSzamonkeresUids = [];
      json['BejelentettSzamonkeresUids'].forEach((v) {
        bejelentettSzamonkeresUids.add(v);
      });
    }
    bejelentettSzamonkeresUid = json['BejelentettSzamonkeresUid'];
    datumString = json['Datum'];
    datum = datumString != null
        ? DateTime.parse(datumString).toLocal()
        : DateTime(2020);
    helyettesTanarNeve = json['HelyettesTanarNeve'];
    isTanuloHaziFeladatEnabled = json['IsTanuloHaziFeladatEnabled'];
    kezdetIdopontString = json['KezdetIdopont'];
    kezdetIdopont = kezdetIdopontString != null
        ? DateTime.parse(kezdetIdopontString).toLocal()
        : DateTime(2020);
    nev = json['Nev'];
    oraszam = json['Oraszam'];
    oraEvesSorszama = json['OraEvesSorszama'];
    osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    haziFeladatUid = json['HaziFeladatUid'];
    isHaziFeladatMegoldva = json['IsHaziFeladatMegoldva'];
    tanarNeve = json['TanarNeve'];
    tantargy = json['Tantargy'] != null
        ? new Tantargy.fromJson(json['Tantargy'])
        : null;
    tanuloJelenlet = json['TanuloJelenlet'] != null
        ? new Leiras.fromJson(json['TanuloJelenlet'])
        : null;
    tema = json['Tema'];
    teremNeve = json['TeremNeve'];
    tipus = json['Tipus'] != null ? new Leiras.fromJson(json['Tipus']) : null;
    uid = json['Uid'];
    vegIdopontString = json['VegIdopont'];
    vegIdopont = vegIdopontString != null
        ? DateTime.parse(vegIdopontString).toLocal()
        : DateTime(2020);
    icon = parseSubjectToIcon(subject: tantargy.nev);
  }

  @override
  String toString() {
    return this.datum.toLocal().toIso8601String();
  }
}
