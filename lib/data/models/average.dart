class Average {
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

//TODO: Merge these two classes
//FIXME: Andrew says his average calculations are not always right
class AV {
  double value;
  double diffSinceLast;
  String subject = "";
  double count = 0;

  @override
  String toString() {
    return subject + ":" + value.toStringAsFixed(3);
  }

  Average toDatabaseAverage() {
    Average temp = new Average();
    temp.ownValue = value;
    temp.subject = subject;
    return temp;
  }
}
