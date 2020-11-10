import 'leiras.dart';
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
  String tantargy;
  Leiras tipus;
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
    datum = datumString != null ? DateTime.parse(datumString) : DateTime(2020);
    keszitesDatumaString = json['KeszitesDatuma'];
    keszitesDatuma = keszitesDatumaString != null
        ? DateTime.parse(keszitesDatumaString)
        : DateTime(2020);
    tanar = json['KeszitoTanarNeve'];
    lattamozasDatumaString = json['LattamozasDatuma'];
    lattamozasDatuma = lattamozasDatumaString != null
        ? DateTime.parse(lattamozasDatumaString)
        : DateTime(2020);
    osztalyCsoport = json['OsztalyCsoport'] != null
        ? new OsztalyCsoport.fromJson(json['OsztalyCsoport'])
        : null;
    tartalom = json['Tartalom'];
    tipus = json['Tipus'] != null ? new Leiras.fromJson(json['Tipus']) : null;
    uid = json['Uid'];
  }
}
