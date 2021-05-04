import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
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

  Subject.fromDatabaseId(
    String inpUID,
    String teacher, {
    @required int dbId,
    @required String dbUid,
    @required String dbName,
  }) {
    if (subjectMap[inpUID] == null) {
      try {
        Map<String, dynamic> decoded = json.decode(inpUID);
        uid = decoded["Uid"];
        uid +=
            teacher == null ? "" : md5.convert(utf8.encode(teacher)).toString();
        category = Description.fromJson(json.decode(decoded['Kategoria']));
        fullName = decoded["Nev"];
        name = shortenSubject(this);
        subjectMap[uid] = this;
        DatabaseHelper.updateSubject(
          dbId: dbId,
          uid: dbUid,
          dbName: dbName,
          subject: this.uid,
        );
        DatabaseHelper.insertSubject(this, teacher);
      } catch (e) {
        uid = inpUID;
        uid +=
            teacher == null ? "" : md5.convert(utf8.encode(teacher)).toString();
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

  Subject.fromJson(Map<String, dynamic> inpJson, String teacher) {
    uid = inpJson['Uid'];
    uid += teacher == null ? "" : md5.convert(utf8.encode(teacher)).toString();
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
