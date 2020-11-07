class Event {
  int databaseId;
  int id;
  String dateString;
  String endDateString;
  DateTime date;
  DateTime endDate;
  String title;
  String content;
  Event();

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'dateString': dateString,
      'endDateString': endDateString,
      'title': title,
      'content': content,
    };
  }

  Event.fromJson(Map<String, dynamic> json) {
    id = json["EventId"];
    dateString = json["Date"];
    date = DateTime.parse(json["Date"]);
    endDateString = json["EndDate"];
    endDate = DateTime.parse(json["EndDate"]);
    content = json["Content"];
    content = content.replaceAll("\n", "<br>");
    title = json["Title"];
  }
}
