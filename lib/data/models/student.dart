import 'dart:convert';
import 'package:flutter/material.dart';

class Student {
  String mothersName;
  List<String> addressList;
  List<Parent> parents;
  String name;
  String nickname;
  String birthDayString;
  DateTime birthDay;
  String placeOfBirth;
  String birthName;
  String schoolYearUid;
  String uid;
  BankAccount bankAccount;
  //Should I merge these two?
  Institution institution;

  String school;
  String username;
  String password;
  String token;
  String refreshToken;

  /// Date of login
  DateTime tokenDate;
  int userId;
  bool current;
  bool fetched = false;

  Color color;

  Student({
    this.mothersName,
    this.addressList,
    this.parents,
    this.name,
    this.nickname,
    this.birthDayString,
    this.birthDay,
    this.placeOfBirth,
    this.birthName,
    this.schoolYearUid,
    this.uid,
    this.bankAccount,
    this.institution,
    this.username,
    this.password,
    this.school,
    this.token,
    this.refreshToken,
    this.tokenDate,
    this.userId,
    this.current,
    this.fetched = false,
    this.color,
  });

  @override
  String toString() {
    return this.name + ":" + this.tokenDate.toString() + ":" + this.school;
  }

  Student.from(Student input) {
    userId = input.userId;
    uid = input.uid;
    mothersName = input.mothersName;
    addressList = input.addressList;
    parents = input.parents;
    name = input.name;
    nickname = input.nickname;
    birthDayString = input.birthDayString;
    birthDay = input.birthDay;
    placeOfBirth = input.placeOfBirth;
    birthName = input.birthName;
    schoolYearUid = input.schoolYearUid;
    bankAccount = input.bankAccount;
    institution = input.institution;
    current = input.current;
    school = input.school;
    username = input.username;
    password = input.password;
    token = input.token;
    refreshToken = input.refreshToken;
    fetched = input.fetched;
    color = input.color;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'uid': uid,
      'mothersName': mothersName,
      'adressList': json.encode(addressList),
      'parents': json.encode(parents),
      'name': name,
      'nickname': nickname,
      'birthDay': birthDayString,
      'placeOfBirth': placeOfBirth,
      'birthName': birthName,
      'schoolYearUid': schoolYearUid,
      'bankAccount': bankAccount.toJson(),
      'institution': institution.toJson(),
      'username': username,
      'school': school,
      'current': current ? 1 : 0,
      'fetched': fetched ? 1 : 0,
      'color': color?.value ?? Colors.orange.value,
      'refreshToken': refreshToken,
    };
  }

  Student.fromJson(Map<String, dynamic> json) {
    mothersName = json['AnyjaNeve'];
    addressList = json['Cimek'].cast<String>();
    if (json['Gondviselok'] != null) {
      parents = <Parent>[];
      json['Gondviselok'].forEach((v) {
        parents.add(new Parent.fromJson(v));
      });
    }
    name = json['Nev'];
    birthDayString = json['SzuletesiDatum'];
    birthDay = DateTime.parse(birthDayString).toLocal();
    placeOfBirth = json['SzuletesiHely'];
    birthName = json['SzuletesiNev'];
    schoolYearUid = json['TanevUid'];
    uid = json['Uid'];
    bankAccount = json['Bankszamla'] != null
        ? new BankAccount.fromJson(json['Bankszamla'])
        : null;
    institution = json['Intezmeny'] != null
        ? new Institution.fromJson(json['Intezmeny'])
        : Institution();
    institution.name = json['IntezmenyNev'];
    institution.linkId = json['IntezmenyAzonosito'];
  }

  Student.fromSqlite(Map<String, dynamic> map) {
    userId = map['id'];
    uid = map['uid'];
    mothersName = map['mothersName'];
    addressList = json.decode(map['adressList']).cast<String>();
    parents = Parent.fromJsonList(map['parents']);
    name = map['name'];
    nickname = map['nickname'];
    birthDayString = map['birthDay'];
    birthDay = DateTime.parse(map['birthDay']).toLocal();
    placeOfBirth = map['placeOfBirth'];
    birthName = map['birthName'];
    schoolYearUid = map['schoolYearUid'];
    bankAccount = BankAccount.fromJson(json.decode(map['bankAccount']));
    institution = Institution.fromJson(json.decode(map['institution']));
    school = map['school'];
    username = map['username'];
    password = map['password'];
    current = map['current'] == 1;
    fetched = map['fetched'] == 1;
    color = Color(map['color']);
    refreshToken = map['refreshToken'];
  }
}

class Parent {
  String email;
  String name;
  String phoneNumber;
  String uid;
  bool isLegalGuardian;
  Parent();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['EmailCim'] = this.email;
    data['Nev'] = this.name;
    data['Telefonszam'] = this.phoneNumber;
    data['Uid'] = this.uid;
    data['IsTorvenyesKepviselo'] = this.isLegalGuardian;
    return data;
  }

  static List<Parent> fromJsonList(dynamic inputJson) {
    List<Parent> tempList = [];
    for (var n in json.decode(inputJson)) {
      tempList.add(Parent.fromJson(n));
    }
    return tempList;
  }

  Parent.fromJson(Map<String, dynamic> json) {
    email = json['EmailCim'];
    name = json['Nev'];
    phoneNumber = json['Telefonszam'];
    uid = json['Uid'];
    isLegalGuardian = json['IsTorvenyesKepviselo'];
  }
}

class BankAccount {
  String accountNumber;
  int accountHolderTypeId;
  String accountHolderName;
  bool isReadOnly;
  BankAccount();

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BankszamlaSzam'] = this.accountNumber;
    data['BankszamlaTulajdonosTipusId'] = this.accountHolderTypeId;
    data['BankszamlaTulajdonosNeve'] = this.accountHolderName;
    data['IsReadOnly'] = this.isReadOnly;
    return json.encode(data);
  }

  BankAccount.fromJson(Map<String, dynamic> json) {
    accountNumber = json['BankszamlaSzam'];
    accountHolderTypeId = json['BankszamlaTulajdonosTipusId'];
    accountHolderName = json['BankszamlaTulajdonosNeve'];
    isReadOnly = json['IsReadOnly'];
  }
}

class Institution {
  String uid;
  String linkId;
  String shortName;
  String name;
  int userPosition = 0;
  List<SystemModules> systemModules;
  CustomizationOptions customizationOptions;
  Institution();

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Uid'] = this.uid;
    data['RovidNev'] = this.shortName;
    if (this.systemModules != null) {
      data['Rendszermodulok'] =
          this.systemModules.map((v) => v.toJson()).toList();
    }
    if (this.customizationOptions != null) {
      data['TestreszabasBeallitasok'] = this.customizationOptions.toJson();
    }
    data['LinkId'] = this.linkId;
    data['Name'] = this.name;
    data['userPosition'] = this.userPosition;
    return json.encode(data);
  }

  Institution.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    shortName = json['RovidNev'];
    if (json['Rendszermodulok'] != null) {
      systemModules = <SystemModules>[];
      json['Rendszermodulok'].forEach((v) {
        systemModules.add(new SystemModules.fromJson(v));
      });
    }
    customizationOptions = json['TestreszabasBeallitasok'] != null
        ? new CustomizationOptions.fromJson(json['TestreszabasBeallitasok'])
        : null;
    //* These two are novynaplo internal stuff
    this.linkId = json['LinkId'];
    this.name = json['Name'];
    this.userPosition = json['userPosition'] ?? 0;
  }
}

class SystemModules {
  bool active;
  String type;
  SystemModules();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsAktiv'] = this.active;
    data['Tipus'] = this.type;
    return data;
  }

  SystemModules.fromJson(Map<String, dynamic> json) {
    active = json['IsAktiv'];
    type = json['Tipus'];
  }
}

class CustomizationOptions {
  bool isStudentHomeworkEnabled;
  bool canViewThemeOfLesson;
  bool canViewClassAV;
  int evalShowDelay;
  String nextUpdate;
  CustomizationOptions();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsDiakRogzithetHaziFeladatot'] = this.isStudentHomeworkEnabled;
    data['IsTanorakTemajaMegtekinthetoEllenorzoben'] =
        this.canViewThemeOfLesson;
    data['IsOsztalyAtlagMegjeleniteseEllenorzoben'] = this.canViewClassAV;
    data['ErtekelesekMegjelenitesenekKesleltetesenekMerteke'] =
        this.evalShowDelay;
    data['KovetkezoTelepitesDatuma'] = this.nextUpdate;
    return data;
  }

  CustomizationOptions.fromJson(Map<String, dynamic> json) {
    isStudentHomeworkEnabled = json['IsDiakRogzithetHaziFeladatot'];
    canViewThemeOfLesson = json['IsTanorakTemajaMegtekinthetoEllenorzoben'];
    canViewClassAV = json['IsOsztalyAtlagMegjeleniteseEllenorzoben'];
    evalShowDelay = json['ErtekelesekMegjelenitesenekKesleltetesenekMerteke'];
    nextUpdate = json['KovetkezoTelepitesDatuma'];
  }
}
