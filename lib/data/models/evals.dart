import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'description.dart';
import 'classGroup.dart';
import 'subject.dart';

class Evals {
  int databaseId;
  int userId;
  String uid;
  String teacher;
  Description valueType;
  String kindOf;
  DateTime createDate;
  DateTime seenDate;
  Description mode;
  DateTime date;
  int weight;
  int numberValue;
  String textValue;
  String shortTextValue;
  Subject subject;
  String theme;
  Description type;
  ClassGroup group;
  int sortIndex;
  IconData icon;

  Evals({
    this.teacher,
    this.valueType,
    this.kindOf,
    this.createDate,
    this.seenDate,
    this.mode,
    this.date,
    this.weight,
    this.numberValue,
    this.textValue,
    this.shortTextValue,
    this.subject,
    this.theme,
    this.type,
    this.group,
    this.sortIndex,
    this.uid,
  });

  @override
  String toString() {
    return this.subject.name;
  }

  Evals.fromJson(Map<String, dynamic> json, Student userDetails) {
    userId = userDetails.userId;
    teacher = json['ErtekeloTanarNeve'];
    valueType = json['ErtekFajta'] != null
        ? new Description.fromJson(json['ErtekFajta'])
        : null;
    kindOf = json['Jelleg'];
    createDate = json['KeszitesDatuma'] != null
        ? DateTime.parse(json['KeszitesDatuma']).toLocal()
        : DateTime(2020);
    seenDate = json['LattamozasDatuma'] != null
        ? DateTime.parse(json['LattamozasDatuma']).toLocal()
        : DateTime(2020);
    mode = json['Mod'] != null ? new Description.fromJson(json['Mod']) : null;
    date = json['RogzitesDatuma'] != null
        ? DateTime.parse(json['RogzitesDatuma']).toLocal()
        : DateTime(2020);
    weight = json['SulySzazalekErteke'];
    numberValue = json['SzamErtek'];
    textValue = json['SzovegesErtek'];
    shortTextValue = json['SzovegesErtekelesRovidNev'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(json['Tantargy'])
        : null;
    theme = json['Tema'];
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    sortIndex = json['SortIndex'];
    uid = json['Uid'];
    if (theme == null) {
      theme = mode.description;
    }
    icon = parseSubjectToIcon(subject: subject.name);
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'userId': userId,
      'uid': uid,
      'teacher': teacher,
      'valueType': valueType.toJson(),
      'kindOf': kindOf,
      'createDate': createDate.toIso8601String(),
      'seenDate': seenDate.toIso8601String(),
      'mode': mode.toJson(),
      'date': date.toIso8601String(),
      'weight': weight,
      'numberValue': numberValue,
      'textValue': textValue,
      'shortTextValue': shortTextValue,
      'subject': subject.toJson(),
      'theme': theme,
      'type': type.toJson(),
      'group': group.toJson(),
      'sortIndex': sortIndex,
    };
  }
}
