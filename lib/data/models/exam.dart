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
  Exam();

  Exam.fromJson(Map<String, dynamic> json) {
    id = json["Id"];
    dateWriteString = json["Datum"];
    dateWrite = DateTime.parse(json["Datum"]);
    dateGivenUpString = json["BejelentesDatuma"];
    dateGivenUp = DateTime.parse(json["BejelentesDatuma"]);
    subject = json["Tantargy"];
    teacher = json["Tanar"];
    nameOfExam = json["SzamonkeresMegnevezese"];
    typeOfExam = json["SzamonkeresModja"];
    classGroupId = json["OsztalyCsoportUid"];
  }

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
