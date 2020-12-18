class ClassGroup {
  String uid;
  String name;

  ClassGroup({this.uid});

  ClassGroup.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    name = json['Nev'];
  }
}
