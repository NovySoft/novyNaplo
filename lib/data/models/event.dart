import 'package:novynaplo/data/models/student.dart';

class Event {
  int databaseId;
  String uid;
  DateTime startDate;
  DateTime endDate;
  String title;
  String content;
  int userId;

  Event({
    this.startDate,
    this.endDate,
    this.title,
    this.content,
  });

  Event.fromJson(Map json, Student userDetails) {
    userId = userDetails.userId;
    uid = json["Uid"];
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
      return '<a href="${m.group(0)}">${m.group(0)}</a>';
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'uid': uid,
      'startDate':
          startDate == null ? null : startDate.toUtc().toIso8601String(),
      'endDate': endDate == null ? null : endDate.toUtc().toIso8601String(),
      'title': title,
      'content': content,
      'userId': userId,
    };
  }
}
