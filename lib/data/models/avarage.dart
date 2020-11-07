class Avarage {
  String subject;
  double ownValue;
  int databaseId;

  @override
  String toString() {
    return this.subject + ": " + this.ownValue.toStringAsFixed(3);
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'subject': subject,
      'ownValue': ownValue,
    };
  }
}
