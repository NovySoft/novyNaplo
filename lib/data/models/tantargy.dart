import 'package:novynaplo/helpers/misc/shortenSubject.dart';
import 'leiras.dart';

class Tantargy {
  String uid;
  Leiras kategoria;
  String nev;

  Tantargy({this.uid, this.kategoria, this.nev});

  Tantargy.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    kategoria = json['Kategoria'] != null
        ? new Leiras.fromJson(json['Kategoria'])
        : null;
    nev = shortenSubject(json['Nev']);
  }
}
