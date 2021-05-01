import 'dart:convert';

import 'package:novynaplo/helpers/misc/shortenSubject.dart';
import 'description.dart';

class Subject {
  String uid;
  Description category;
  String name;
  String fullName;

  Subject({this.uid, this.category, this.name, this.fullName});

  //TODO: I believe this can be optimized further
  Subject.fromJson(Map<String, dynamic> inpJson) {
    uid = inpJson['Uid'];
    category = inpJson['Kategoria'] != null
        ? new Description.fromJson(inpJson['Kategoria'].runtimeType == String
            ? json.decode(inpJson['Kategoria'])
            : inpJson['Kategoria'])
        : null;
    fullName = inpJson['Nev'];
    name = shortenSubject(this);
  }

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Uid'] = this.uid;
    data['Kategoria'] = this.category;
    data['Nev'] = this.fullName;
    return json.encode(data);
  }
}
