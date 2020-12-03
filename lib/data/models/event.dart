class Event {
  int id;
  int databaseId;
  String uid;
  DateTime ervenyessegKezdete;
  DateTime ervenyessegVege;
  String cim;
  String tartalom;

  Event({
    this.id,
    this.ervenyessegKezdete,
    this.ervenyessegVege,
    this.cim,
    this.tartalom,
  });

  Event.fromJson(Map json) {
    uid = json["Uid"] ?? "";
    id = uid == null || uid == "" ? null : int.parse(uid);
    ervenyessegKezdete = json["ErvenyessegKezdete"] != null
        ? DateTime.parse(json["ErvenyessegKezdete"]).toLocal()
        : null;
    ervenyessegVege = json["ErvenyessegVege"] != null
        ? DateTime.parse(json["ErvenyessegVege"]).toLocal()
        : null;
    cim = json["Cim"] ?? "";
    tartalom = json["Tartalom"] != null
        ? json["Tartalom"].replaceAll("\r", "<br>").replaceAll("\n", "<br>")
        : null;
  }
}
