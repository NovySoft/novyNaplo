import 'package:flutter/cupertino.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';

import 'leiras.dart';
import 'osztalyCsoport.dart';
import 'tantargy.dart';

class Exam {
  String bejelentesDatumaString;
  DateTime bejelentesDatuma;
  String datumString;
  DateTime datum;
  Leiras modja;
  int orarendiOraOraszama;
  String tanar;
  Tantargy tantargy;
  String tema;
  OsztalyCsoport osztalyCsoport;
  String uid;
  int id;
  IconData icon;

  Exam(
      {this.bejelentesDatuma,
      this.datum,
      this.modja,
      this.orarendiOraOraszama,
      this.tanar,
      this.tantargy,
      this.tema,
      this.osztalyCsoport,
      this.uid});

  Exam.fromJson(Map<String, dynamic> json) {
    bejelentesDatumaString = json['BejelentesDatuma'];
    bejelentesDatuma = bejelentesDatumaString != null
        ? DateTime.parse(bejelentesDatumaString).toLocal()
        : DateTime(2020);
    datumString = json['Datum'];
    datum = datumString != null
        ? DateTime.parse(datumString).toLocal()
        : DateTime(2020);
    modja = json['Modja'] != null ? new Leiras.fromJson(json['Modja']) : null;
    orarendiOraOraszama = json['OrarendiOraOraszama'];
    tanar = json['RogzitoTanarNeve'];
    tantargy = json['Tantargy'] != null
        ? new Tantargy.fromJson(json['Tantargy'])
        : null;
    tema = json['Temaja'];
    osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
    id = int.parse(uid);
    icon = parseSubjectToIcon(subject: tantargy.nev);
  }
}
