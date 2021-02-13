class Average {
  double value;
  double diffSinceLast;
  String subject = "";
  double count = 0;
  int databaseId;
  int userId;

  int nonWeightedCount;

  @override
  String toString() {
    return this.subject +
        ": " +
        this.value.toStringAsFixed(3);
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'subject': subject,
      'ownValue': value,
      'userId': userId,
    };
  }
}
