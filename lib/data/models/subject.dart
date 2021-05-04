import 'dart:convert';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/helpers/misc/shortenSubject.dart';
import 'description.dart';

Map<String, Subject> subjectMap = new Map<String, Subject>();

class Subject {
  String uid;
  Description category;
  String name;
  String fullName;

  bool isSameKretaSide(Subject other) {
    //!Doesn't check nickname!
    if (other == null) return false;
    return uid == other.uid && fullName == other.fullName;
  }

  Subject({this.uid, this.category, this.name, this.fullName});

  Subject.fromDatabaseId(String inpUID) {
    if (subjectMap[inpUID] == null) {
      try {
        Map<String, dynamic> decoded = json.decode(inpUID);
        uid = decoded["Uid"];
        category = Description.fromJson(json.decode(decoded['Kategoria']));
        fullName = decoded["Nev"];
        name = shortenSubject(this);
      } catch (e) {
        uid = inpUID;
        category = Description(
          uid: inpUID,
          name: inpUID,
          description: inpUID,
        );
        name = inpUID;
        fullName = inpUID;
      }
    } else {
      uid = inpUID;
      category = subjectMap[inpUID].category;
      name = subjectMap[inpUID].name;
      fullName = subjectMap[inpUID].fullName;
    }
  }

  Subject.fromSqlite(Map<String, dynamic> map) {
    uid = map['uid'];
    category = Description.fromJson(json.decode(map['category']));
    name = map['nickname'];
    fullName = map['fullname'];
  }

  Subject.fromJson(Map<String, dynamic> inpJson, String type, String teacher) {
    uid = inpJson['Uid'];
    uid += type;
    category = inpJson['Kategoria'] != null
        ? new Description.fromJson(inpJson['Kategoria'].runtimeType == String
            ? json.decode(inpJson['Kategoria'])
            : inpJson['Kategoria'])
        : null;
    fullName = inpJson['Nev'];
    name = shortenSubject(this);
    if (!this.isSameKretaSide(subjectMap[uid])) {
      DatabaseHelper.insertSubject(this, teacher);
      subjectMap[uid] = this;
    }
  }

  @override
  String toString() => "$uid:$fullName";
}
