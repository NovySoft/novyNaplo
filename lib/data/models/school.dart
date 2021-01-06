class School {
  int id;
  String name;
  String code;
  String url;
  String city;
  School();

  School.fromJson(Map<String, dynamic> json) {
    id = json["InstituteId"];
    name = json["Name"];
    code = json["InstituteCode"];
    url = json["Url"];
    city = json["City"];
  }
}
