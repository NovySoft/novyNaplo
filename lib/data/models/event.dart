class Event {
  int databaseId;
  int id;
  String dateString;
  String endDateString;
  DateTime date;
  DateTime endDate;
  String title;
  String content;

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
}
