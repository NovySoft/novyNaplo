import 'dart:convert';

class ClassGroup {
  String uid;
  String name;

  ClassGroup({this.uid, this.name});

  ClassGroup.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    name = json['Nev'];
  }

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Uid'] = this.uid;
    data['Nev'] = this.name;
    return json.encode(data);
  }
}
