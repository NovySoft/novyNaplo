import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/htmlLinkify.dart';

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

  Event.fromSqlite(Map<String, dynamic> map) {
    databaseId = map['databaseId'];
    uid = map['uid'];
    startDate = map['startDate'] == null
        ? null
        : DateTime.parse(map['startDate']).toLocal();
    endDate = map['endDate'] == null
        ? null
        : DateTime.parse(map['endDate']).toLocal();
    title = map['title'];
    content = map['content'];
    userId = map['userId'];
  }

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
    content = htmlLinkify(content);
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
