class OsztalyCsoport {
  String uid;
  String nev;

  OsztalyCsoport({this.uid});

  OsztalyCsoport.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    nev = json['Nev'];
  }
}
