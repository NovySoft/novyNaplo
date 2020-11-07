class Exam {
  int databaseId;
  int id;
  String dateWriteString;
  DateTime dateWrite;
  String dateGivenUpString;
  DateTime dateGivenUp;
  String subject;
  String teacher;
  String nameOfExam; //Content
  String typeOfExam;
  String classGroupId;

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'classGroupId': classGroupId,
      'subject': subject,
      'teacher': teacher,
      'typeOfExam': typeOfExam,
      'nameOfExam': nameOfExam,
      'dateGivenUpString': dateGivenUpString,
      'dateWriteString': dateWriteString,
    };
  }
}
