import 'dart:convert';

import 'package:novynaplo/helpers/misc/shortenSubject.dart';
import 'description.dart';

class Subject {
  String uid;
  Description kategory;
  String name;
  String shortName;

  Subject({this.uid, this.kategory, this.name});

  Subject.fromJson(Map<String, dynamic> inpJson) {
    uid = inpJson['Uid'];
    kategory = inpJson['Kategoria'] != null
        ? new Description.fromJson(inpJson['Kategoria'].runtimeType == String
            ? json.decode(inpJson['Kategoria'])
            : inpJson['Kategoria'])
        : null;
    name = inpJson['Nev'];
    shortName = shortenSubject(name);
  }

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Uid'] = this.uid;
    data['Kategoria'] = this.kategory;
    data['Nev'] = this.name;
    return json.encode(data);
  }
}
