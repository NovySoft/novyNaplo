class Description {
  String uid;
  String description;
  String name;

  Description({this.uid, this.description, this.name});

  Description.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    description = json['Leiras'];
    name = json['Nev'];
  }
}
