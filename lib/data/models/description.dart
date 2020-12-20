import 'dart:convert';

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

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Uid'] = this.uid;
    data['Leiras'] = this.description;
    data['Nev'] = this.name;
    return json.encode(data);
  }
}
