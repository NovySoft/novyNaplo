import 'package:novynaplo/helpers/misc/shortenSubject.dart';
import 'description.dart';

class Subject {
  String uid;
  Description kategory;
  String name;

  Subject({this.uid, this.kategory, this.name});

  Subject.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    kategory = json['Kategoria'] != null
        ? new Description.fromJson(json['Kategoria'])
        : null;
    name = shortenSubject(json['Nev']);
  }
}
