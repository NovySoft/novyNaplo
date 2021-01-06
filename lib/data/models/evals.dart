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
  double numberValueAsMark; //Used to calculate statistics
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
    return this.subject.name + ":" + this.date.toString();
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
        case "Elégtelen":
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
      numberValue = json["SzamErtek"];
    }
    textValue = json['SzovegesErtek'];
    if (numberValue == 0 || numberValue == null) {
      //Search for percentages in the text value
      RegExp regex = RegExp(
        r'\b(?<!\.)(?!0+(?:\.0+)?%)(?:\d|[1-9]\d|100)(?:(?<!100)\.\d+)?%',
        multiLine: true,
        caseSensitive: false,
      );
      RegExpMatch value = regex.firstMatch(textValue);
      numberValue = value == null
          ? 0
          : int.parse(
              value.group(0).split("%")[0],
            );
      if (value != null) {
        valueType = Description(
          uid: "-1,NovyNaplóCalc",
          description: "Percentage Calculated By NovyNapló",
          name: "Szazalekos",
        );
      } else {
        if (textValue.toLowerCase().contains("kiváló")) {
          numberValue = 5;
        } else if (textValue.toLowerCase().contains("jó")) {
          numberValue = 4;
        } else if (textValue.toLowerCase().contains("megfelelő")) {
          numberValue = 3;
        } else {
          numberValue = 0;
        }
        //FIXME Mi a többi érték?
      }
    }
    shortTextValue = json['SzovegesErtekelesRovidNev'];
    subject = json['Tantargy'] != null
        ? new Subject.fromJson(json['Tantargy'])
        : null;
    theme = json['Tema'];
    group = json['OsztalyCsoport'] != null
        ? new ClassGroup.fromJson(json['OsztalyCsoport'])
        : null;
    sortIndex = json['SortIndex'];
    uid = json['Uid'];
    if (theme == null) {
      if (mode != null) {
        theme = mode.description;
      } else {
        //mode is null when it is a magatartás/szorgalom mark
        theme = subject.name;
      }
    }
    icon = subject.name == null
        ? Icons.create
        : parseSubjectToIcon(subject: subject.name);
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
      'subject': subject == null ? null : subject.toJson(),
      'theme': theme,
      'type': type == null ? null : type.toJson(),
      'group': group == null ? null : group.toJson(),
      'sortIndex': sortIndex,
    };
  }
}
