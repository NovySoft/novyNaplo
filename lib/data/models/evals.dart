import 'dart:convert';

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
  double numberValue;
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
    //return this.valueType.name;
    return this.subject.name + ":" + this.date.toString();
  }

  Evals.fromSqlite(Map<String, dynamic> map) {
    databaseId = map['databaseId'];
    userId = map['userId'];
    uid = map['uid'];
    teacher = map['teacher'];
    valueType = map['valueType'] == null
        ? null
        : Description.fromJson(json.decode(map['valueType']));
    kindOf = map['kindOf'];
    createDate = map['createDate'] == null
        ? null
        : DateTime.parse(map['createDate']).toLocal();
    seenDate = map['seenDate'] == null
        ? null
        : DateTime.parse(map['seenDate']).toLocal();
    mode = map['mode'] == null
        ? null
        : Description.fromJson(json.decode(map['mode']));
    date = map['date'] == null ? null : DateTime.parse(map['date']).toLocal();
    weight = map['weight'];
    numberValue = map['numberValue'];
    textValue = map['textValue'];
    shortTextValue = map['shortTextValue'];
    subject =
        map['subject'] == null ? null : Subject.fromDatabaseId(map['subject']);
    theme = map['theme'];
    type = map['type'] == null
        ? null
        : Description.fromJson(json.decode(map['type']));
    group = map['group'] == null
        ? null
        : ClassGroup.fromJson(json.decode(map['group']));
    sortIndex = map['sortIndex'];
    icon = subject != null
        ? parseSubjectToIcon(subject: subject.fullName)
        : Icons.create;
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
        : null;
    seenDate = json['LattamozasDatuma'] != null
        ? DateTime.parse(json['LattamozasDatuma']).toLocal()
        : null;
    mode = json['Mod'] != null ? new Description.fromJson(json['Mod']) : null;
    date = json['RogzitesDatuma'] != null
        ? DateTime.parse(json['RogzitesDatuma']).toLocal()
        : null;
    weight =
        json['SulySzazalekErteke'] == null ? 100 : json['SulySzazalekErteke'];
    type =
        json['Tipus'] != null ? new Description.fromJson(json['Tipus']) : null;
    if ((json["SzamErtek"] == 0 || json["SzamErtek"] == null) &&
        valueType.name != "Szazalekos") {
      switch (json["SzovegesErtek"]) {
        case "Hanyag":
          numberValue = 1;
          break;
        case "Rossz":
          numberValue = 2;
          break;
        case "Változó":
          numberValue = 3;
          break;
        case "Jó":
          numberValue = 4;
          break;
        case "Példás":
          numberValue = 5;
          break;
        default:
          numberValue = 0;
          break;
      }
    } else {
      numberValue = double.parse(json["SzamErtek"].toString());
    }
    textValue = json['SzovegesErtek'];
    if (numberValue == 0 || numberValue == null) {
      //Search for percentages in the text value
      RegExp regex = RegExp(
        r'\b(?<!\.)(?!0+(?:\.0+)?%)(?:\d|[1-9]\d|100)(?:(?<!100)\.\d+)?%',
        multiLine: true,
        caseSensitive: false,
      );
      RegExpMatch value = regex.firstMatch(textValue.replaceAll(",", "."));
      numberValue = value == null
          ? 0
          : double.parse(
              value.group(0).split("%")[0],
            );
      if (value != null) {
        valueType = Description(
          uid: "-1,NovyNaplóCalc",
          description: "Percentage Calculated By NovyNapló",
          name: "Szazalekos",
        );
      } else {
        if (textValue.toLowerCase().contains("kiváló") ||
            textValue.toLowerCase().contains("jeles") ||
            textValue.toLowerCase().contains("példás")) {
          numberValue = 5;
        } else if (textValue.toLowerCase().contains("jó")) {
          numberValue = 4;
        } else if (textValue.toLowerCase().contains("megfelelő") ||
            textValue.toLowerCase().contains("közepes") ||
            textValue.toLowerCase().contains("változó")) {
          numberValue = 3;
        } else if (textValue.toLowerCase().contains("rossz") ||
            textValue.toLowerCase().contains("elégséges") ||
            textValue.toLowerCase().contains("hanyag")) {
          numberValue = 2;
        } else if (textValue.toLowerCase().contains("elégtelen")) {
          numberValue = 1;
        } else {
          numberValue = 0;
        }
      }
    }
    shortTextValue = json['SzovegesErtekelesRovidNev'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(
            json['Tantargy'],
            "eval",
            null,
          )
        : null;
    theme = json['Tema'];
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    sortIndex = json['SortIndex'];
    try {
      uid = json['Uid'].split(',')[0];
    } catch (e) {
      uid = json['Uid'];
    }
    //We need this, stupid kreta, I hate them for this....
    uid = uid + kindOf + "${date.year}${date.month}${date.day}";
    if (theme == null) {
      if (mode != null) {
        theme = mode.description;
      } else if (type != null) {
        theme = type.description;
      } else {
        theme = subject.fullName;
      }
    }
    icon = subject.fullName == null
        ? Icons.create
        : parseSubjectToIcon(subject: subject.fullName);
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'userId': userId,
      'uid': uid,
      'teacher': teacher,
      'valueType': valueType == null ? null : valueType.toJson(),
      'kindOf': kindOf,
      'createDate':
          createDate == null ? null : createDate.toUtc().toIso8601String(),
      'seenDate': seenDate == null ? null : seenDate.toUtc().toIso8601String(),
      'mode': mode == null ? null : mode.toJson(),
      'date': date == null ? null : date.toUtc().toIso8601String(),
      'weight': weight,
      'numberValue': numberValue,
      'textValue': textValue,
      'shortTextValue': shortTextValue,
      'subject': subject == null ? null : subject.uid,
      'theme': theme,
      'type': type == null ? null : type.toJson(),
      'group': group == null ? null : group.toJson(),
      'sortIndex': sortIndex,
    };
  }

  //These marks should not be calculated in averages
  static List<String> nonAvTypes = [
    "I_ne_jegy_ertekeles",
    "felevi_jegy_ertekeles",
    "II_ne_jegy_ertekeles",
    "III_ne_jegy_ertekeles",
    "evvegi_jegy_ertekeles",
    "IV_ne_jegy_ertekeles",
  ];
}
