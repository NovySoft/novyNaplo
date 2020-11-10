class Leiras {
  String uid;
  String leiras;
  String nev;

  Leiras({this.uid, this.leiras, this.nev});

  Leiras.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    leiras = json['Leiras'];
    nev = json['Nev'];
  }
}
