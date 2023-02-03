class Average {
  double value;
  double diffSinceLast;
  String subjectName = "";
  String subjectUid = "";
  double count = 0;
  int databaseId;
  int userId;

  int nonWeightedCount;
  double classAverage = 0;

  Average({this.value, this.subjectName, this.subjectUid, this.count, this.databaseId, this.userId, this.classAverage, this.nonWeightedCount, this.diffSinceLast});

  @override
  String toString() {
    return this.subjectName + ": " + this.value.toStringAsFixed(3);
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'subject': subjectUid,
      'ownValue': value,
      'classValue': classAverage,
      'userId': userId,
    };
  }
}
