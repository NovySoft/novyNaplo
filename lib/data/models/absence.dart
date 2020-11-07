class Absence {
  int databaseId;
  int id;
  String type;
  String typeName;
  String subject;
  int delayTimeMinutes;
  String teacher;
  String lessonStartTimeString;
  int numberOfLessons;
  String creatingTime;
  String justificationState;
  String justificationStateName;
  String justificationType;
  String justificationTypeName;
  String osztalyCsoportUid;
  Absence();

  //TODO Make other classes use this syntax instead of an outside function
  Absence.fromJson(Map<String, dynamic> json) {
    id = json['AbsenceId'];
    type = json['Type'];
    typeName = json['TypeName'];
    subject = json['Subject'];
    delayTimeMinutes = json['DelayTimeMinutes'];
    teacher = json['Teacher'];
    lessonStartTimeString = json['LessonStartTime'];
    creatingTime = json['CreatingTime'];
    justificationStateName = json['JustificationStateName'];
    justificationTypeName = json['JustificationTypeName'];
    osztalyCsoportUid = json['OsztalyCsoportUid'];
    justificationState = json['JustificationState'];
    justificationType = json['JustificationType'];
    numberOfLessons = json['NumberOfLessons'];
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'type': type,
      'typeName': typeName,
      'subject': subject,
      'delayTimeMinutes': delayTimeMinutes,
      'teacher': teacher,
      'lessonStartTime': lessonStartTimeString,
      'numberOfLessons': numberOfLessons,
      'creatingTime': creatingTime,
      'justificationState': justificationState,
      'justificationStateName': justificationStateName,
      'justificationType': justificationType,
      'justificationTypeName': justificationTypeName,
      'osztalyCsoportUid': osztalyCsoportUid,
    };
  }
}
