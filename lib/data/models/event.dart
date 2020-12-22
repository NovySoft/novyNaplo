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
    //As the ui shows this as an html object we parse all the links into a html tag
    RegExp regex = RegExp(
      r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?',
      multiLine: true,
      caseSensitive: false,
    );
    content = content.replaceAllMapped(regex, (Match m) {
      print(m.group(0));
      return '<a href="${m.group(0)}">${m.group(0)}</a>';
    });
  }
}
