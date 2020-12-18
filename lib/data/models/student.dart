import 'dart:convert';

class Student {
  String mothersName;
  List<String> adressList;
  List<Parent> parents;
  String name;
  String birthDay;
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
  String iv;
  DateTime tokenDate;
  int id;
  bool current;

  Student({
    this.mothersName,
    this.adressList,
    this.parents,
    this.name,
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
    this.iv,
    this.tokenDate,
    this.id,
    this.current,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'mothersName': mothersName,
      'adressList': json.encode(adressList),
      'parents': json.encode(parents),
      'name': name,
      'birthDay': birthDay,
      'placeOfBirth': placeOfBirth,
      'birthName': birthName,
      'schoolYearUid': schoolYearUid,
      'bankAccount': json.encode(bankAccount.toJson()),
      'institution': json.encode(institution.toJson()),
      'username': username,
      'password': password,
      'school': school,
      'iv': iv,
      'current': current ? 1 : 0,
    };
  }

  Student.fromJson(Map<String, dynamic> json) {
    mothersName = json['AnyjaNeve'];
    adressList = json['Cimek'].cast<String>();
    if (json['Gondviselok'] != null) {
      parents = new List<Parent>();
      json['Gondviselok'].forEach((v) {
        parents.add(new Parent.fromJson(v));
      });
    }
    name = json['Nev'];
    birthDay = json['SzuletesiDatum'];
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
}

class Parent {
  String email;
  String name;
  String phoneNumber;
  String uid;
  Parent();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['EmailCim'] = this.email;
    data['Nev'] = this.name;
    data['Telefonszam'] = this.phoneNumber;
    data['Uid'] = this.uid;
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
  }
}

class BankAccount {
  String accountNumber;
  int accountHolderTypeId;
  String accountHolderName;
  bool isReadOnly;
  BankAccount();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BankszamlaSzam'] = this.accountNumber;
    data['BankszamlaTulajdonosTipusId'] = this.accountHolderTypeId;
    data['BankszamlaTulajdonosNeve'] = this.accountHolderName;
    data['IsReadOnly'] = this.isReadOnly;
    return data;
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
  List<SystemModules> systemModules;
  CustomizationOptions customizationOptions;
  Institution();

  Map<String, dynamic> toJson() {
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
    return data;
  }

  Institution.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    shortName = json['RovidNev'];
    if (json['Rendszermodulok'] != null) {
      systemModules = new List<SystemModules>();
      json['Rendszermodulok'].forEach((v) {
        systemModules.add(new SystemModules.fromJson(v));
      });
    }
    customizationOptions = json['TestreszabasBeallitasok'] != null
        ? new CustomizationOptions.fromJson(json['TestreszabasBeallitasok'])
        : null;
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
  CustomizationOptions();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsDiakRogzithetHaziFeladatot'] = this.isStudentHomeworkEnabled;
    data['IsTanorakTemajaMegtekinthetoEllenorzoben'] =
        this.canViewThemeOfLesson;
    data['IsOsztalyAtlagMegjeleniteseEllenorzoben'] = this.canViewClassAV;
    data['ErtekelesekMegjelenitesenekKesleltetesenekMerteke'] =
        this.evalShowDelay;
    return data;
  }

  CustomizationOptions.fromJson(Map<String, dynamic> json) {
    isStudentHomeworkEnabled = json['IsDiakRogzithetHaziFeladatot'];
    canViewThemeOfLesson = json['IsTanorakTemajaMegtekinthetoEllenorzoben'];
    canViewClassAV = json['IsOsztalyAtlagMegjeleniteseEllenorzoben'];
    evalShowDelay = json['ErtekelesekMegjelenitesenekKesleltetesenekMerteke'];
  }
}
