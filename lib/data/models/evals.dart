import 'package:flutter/material.dart';
import 'package:novynaplo/helpers/functions/parseSubjectToIcon.dart';
import 'package:novynaplo/helpers/functions/shortenSubject.dart';

class Evals {
  var formName,
      form,
      value,
      numberValue,
      teacher,
      type,
      subject,
      theme,
      mode,
      weight;
  String dateString;
  String createDateString;
  DateTime createDate;
  DateTime date;
  IconData icon;
  int databaseId;
  int id;
  Evals();

  Evals.fromJson(Map<String, dynamic> json) {
    if (json["Subject"] == null || json["Subject"] == "") {
      subject = json["Jelleg"]["Nev"];
    } else {
      subject = json["Subject"];
    }
    subject = shortenSubject(subject);
    //Icon
    icon = parseSubjectToIcon(subject: subject);
    //Magatartas es Szorgalom integer
    if (json["NumberValue"] == 0 && json["Form"] != "Percent") {
      switch (json["Value"]) {
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
      numberValue = json["NumberValue"];
    }
    //Ertekeles temaja
    if (json["Theme"] == null || json["Theme"] == "") {
      if (json["Mode"] != null) {
        theme = json["Mode"];
      } else {
        //There is no other option than typeName
        theme = json["TypeName"];
      }
    } else {
      theme = json["Theme"];
    }
    //Ertekeles modja
    if (json["Mode"] == null || json["Mode"] == "") {
      mode = json["TypeName"];
    } else {
      mode = json["Mode"];
    }
    //Ertekeles sulya
    if (json["Weight"] == null ||
        json["Weight"] == "" ||
        json["Weight"] == "-") {
      if (json["Form"] != "Percent") {
        weight = "100%";
      } else {
        weight = "0%";
      }
      //feltehetoleg 100%osan beleszámít, pl a szorgalomnal is igy van
    } else {
      weight = json["Weight"];
    }
    id = json[
        "EvaluationId"]; //We see no use for this, because we use databaseIDs most of the times
    value = json["Value"];
    formName = json["FormName"];
    form = json["Form"];
    teacher = json["Teacher"];
    type = json["Type"];
    dateString = json["Date"];
    createDateString = json["CreatingTime"];
    createDate = DateTime.parse(json["CreatingTime"]);
    date = DateTime.parse(json["Date"]);
  }

  @override
  String toString() {
    return """
    subject: $subject 
    teacher: $teacher 
    theme: $theme 
    value: $value 
    numberValue: $numberValue 
    date: ${createDate.toString()}
    mode: $mode 
    formName: $formName 
    form: $form 
    type: $type 
    weight: $weight 
    id: $id 
    dbId: $databaseId \n
    """;
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'id': id,
      'formName': formName,
      'form': form,
      'value': value,
      'numberValue': numberValue,
      'teacher': teacher,
      'type': type,
      'subject': subject,
      'theme': theme,
      'mode': mode,
      'weight': weight,
      'dateString': dateString,
      'createDateString': createDateString,
    };
  }
}
