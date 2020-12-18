class Event {
  int id;
  int databaseId;
  String uid;
  DateTime startDate;
  DateTime endDate;
  String title;
  String content;

  Event({
    this.id,
    this.startDate,
    this.endDate,
    this.title,
    this.content,
  });

  Event.fromJson(Map json) {
    uid = json["Uid"] ?? "";
    id = uid == null || uid == "" ? null : int.parse(uid);
    startDate = json["ErvenyessegKezdete"] != null
        ? DateTime.parse(json["ErvenyessegKezdete"]).toLocal()
        : null;
    endDate = json["ErvenyessegVege"] != null
        ? DateTime.parse(json["ErvenyessegVege"]).toLocal()
        : null;
    title = json["Cim"] ?? "";
    content = json["Tartalom"] != null
        ? json["Tartalom"].replaceAll("\r", "<br>").replaceAll("\n", "<br>")
        : null;
  }
}
