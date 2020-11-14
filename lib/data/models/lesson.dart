import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/leiras.dart';
import 'package:novynaplo/data/models/tantargy.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'exam.dart';
import 'homework.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;

import 'osztalyCsoport.dart';

class Lesson {
  Leiras allapot;
  List<String> bejelentettSzamonkeresUids;
  List<Exam> bejelentettSzamonkeresek;
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
  Homework haziFeladat;
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
  bool isSpecialDayEvent = false;

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

  //FIXME: NULL SAFETY ON ESEMÉNYEK
  static Future<Lesson> fromJson(Map<String, dynamic> json) async {
    Lesson temp = new Lesson();
    temp.datumString = json['Datum'];
    temp.datum = temp.datumString != null
        ? DateTime.parse(temp.datumString).toLocal()
        : DateTime(2020);
    temp.allapot =
        json['Allapot'] != null ? new Leiras.fromJson(json['Allapot']) : null;
    if (json['BejelentettSzamonkeresUids'] != null) {
      temp.bejelentettSzamonkeresUids = [];
      temp.bejelentettSzamonkeresek = [];
      int index = 0;
      for (var v in json['BejelentettSzamonkeresUids']) {
        temp.bejelentettSzamonkeresUids.add(v);
        temp.bejelentettSzamonkeresek.add(
          examsPage.allParsedExams.firstWhere(
            (item) => item.uid == v,
            orElse: () {
              return Exam();
            },
          ),
        );
        index++;
      }
    }
    temp.bejelentettSzamonkeresUid = json['BejelentettSzamonkeresUid'];
    temp.helyettesTanarNeve = json['HelyettesTanarNeve'];
    temp.isTanuloHaziFeladatEnabled = json['IsTanuloHaziFeladatEnabled'];
    temp.kezdetIdopontString = json['KezdetIdopont'];
    temp.kezdetIdopont = temp.kezdetIdopontString != null
        ? DateTime.parse(temp.kezdetIdopontString).toLocal()
        : DateTime(2020);
    temp.nev = json['Nev'];
    temp.oraszam = json['Oraszam'];
    temp.oraEvesSorszama = json['OraEvesSorszama'];
    temp.osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    temp.haziFeladatUid = json['HaziFeladatUid'];
    if (temp.haziFeladatUid != null) {
      temp.haziFeladat = homeworkPage.globalHomework.firstWhere(
        (element) => element.uid == temp.haziFeladatUid,
        orElse: () {
          return null;
        },
      );
    }
    if (temp.haziFeladat == null && temp.haziFeladatUid != null) {
      temp.haziFeladat =
          await RequestHandler.getHomeworkId(temp.haziFeladatUid);
    }
    temp.isHaziFeladatMegoldva = json['IsHaziFeladatMegoldva'];
    temp.tanarNeve = json['TanarNeve'];
    temp.tantargy = json['Tantargy'] != null
        ? new Tantargy.fromJson(json['Tantargy'])
        : null;
    temp.tanuloJelenlet = json['TanuloJelenlet'] != null
        ? new Leiras.fromJson(json['TanuloJelenlet'])
        : null;
    temp.tema = json['Tema'];
    temp.teremNeve = json['TeremNeve'];
    temp.tipus =
        json['Tipus'] != null ? new Leiras.fromJson(json['Tipus']) : null;
    temp.uid = json['Uid'];
    temp.vegIdopontString = json['VegIdopont'];
    temp.vegIdopont = temp.vegIdopontString != null
        ? DateTime.parse(temp.vegIdopontString).toLocal()
        : DateTime(2020);
    temp.icon = parseSubjectToIcon(
        subject: temp.tantargy == null ? "" : temp.tantargy.nev);
    if (temp.tantargy == null) {
      temp.isSpecialDayEvent = true;
    }
    return temp;
  }

  @override
  String toString() {
    return this.datum.toLocal().toIso8601String();
  }
}
