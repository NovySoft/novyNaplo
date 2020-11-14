import 'leiras.dart';
import 'osztalyCsoport.dart';
import 'tantargy.dart';

class Absence {
  String igazolasAllapota;
  Leiras igazolasTipusa;
  int kesesPercben;
  String keszitesDatuma;
  Leiras mod;
  String datum;
  Ora ora;
  String rogzitoTanarNeve;
  Tantargy tantargy;
  Leiras tipus;
  OsztalyCsoport osztalyCsoport;
  String uid;
  int id;
  int databaseId;

  Absence(
      {this.igazolasAllapota,
      this.igazolasTipusa,
      this.kesesPercben,
      this.keszitesDatuma,
      this.mod,
      this.datum,
      this.ora,
      this.rogzitoTanarNeve,
      this.tantargy,
      this.tipus,
      this.osztalyCsoport,
      this.uid});

  Absence.fromJson(Map<String, dynamic> json) {
    igazolasAllapota = json['IgazolasAllapota'];
    igazolasTipusa = json['IgazolasTipusa'] != null
        ? new Leiras.fromJson(json['IgazolasTipusa'])
        : null;
    kesesPercben = json['KesesPercben'];
    keszitesDatuma = json['KeszitesDatuma'];
    mod = json['Mod'] != null ? new Leiras.fromJson(json['Mod']) : null;
    datum = json['Datum'];
    ora = json['Ora'] != null ? new Ora.fromJson(json['Ora']) : null;
    rogzitoTanarNeve = json['RogzitoTanarNeve'];
    tantargy = json['Tantargy'] != null
        ? new Tantargy.fromJson(json['Tantargy'])
        : null;
    tipus = json['Tipus'] != null ? new Leiras.fromJson(json['Tipus']) : null;
    osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    uid = json['Uid'];
  }
}

class Ora {
  String kezdoDatumString;
  DateTime kezdoDatum;
  String vegDatumString;
  DateTime vegDatum;
  int oraszam;

  Ora({this.kezdoDatum, this.vegDatum, this.oraszam});

  Ora.fromJson(Map<String, dynamic> json) {
    kezdoDatumString = json['KezdoDatum'];
    kezdoDatum = DateTime.parse(kezdoDatumString).toLocal();
    vegDatumString = json['VegDatum'];
    vegDatum = DateTime.parse(vegDatumString).toLocal();
    oraszam = json['Oraszam'];
  }
}
