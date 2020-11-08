class Student {
  String anyjaNeve;
  List<String> cimek;
  List<Gondviselok> gondviselok;
  String intezmenyAzonosito;
  String intezmenyNev;
  String nev;
  String szuletesiDatum;
  String szuletesiHely;
  String szuletesiNev;
  String tanevUid;
  String uid;
  Bankszamla bankszamla;
  Intezmeny intezmeny;
  Student();

  Student.fromJson(Map<String, dynamic> json) {
    anyjaNeve = json['AnyjaNeve'];
    cimek = json['Cimek'].cast<String>();
    if (json['Gondviselok'] != null) {
      gondviselok = new List<Gondviselok>();
      json['Gondviselok'].forEach((v) {
        gondviselok.add(new Gondviselok.fromJson(v));
      });
    }
    intezmenyAzonosito = json['IntezmenyAzonosito'];
    intezmenyNev = json['IntezmenyNev'];
    nev = json['Nev'];
    szuletesiDatum = json['SzuletesiDatum'];
    szuletesiHely = json['SzuletesiHely'];
    szuletesiNev = json['SzuletesiNev'];
    tanevUid = json['TanevUid'];
    uid = json['Uid'];
    bankszamla = json['Bankszamla'] != null
        ? new Bankszamla.fromJson(json['Bankszamla'])
        : null;
    intezmeny = json['Intezmeny'] != null
        ? new Intezmeny.fromJson(json['Intezmeny'])
        : null;
  }
}

class Gondviselok {
  String emailCim;
  String nev;
  String telefonszam;
  String uid;
  Gondviselok();

  Gondviselok.fromJson(Map<String, dynamic> json) {
    emailCim = json['EmailCim'];
    nev = json['Nev'];
    telefonszam = json['Telefonszam'];
    uid = json['Uid'];
  }
}

class Bankszamla {
  String bankszamlaSzam;
  int bankszamlaTulajdonosTipusId;
  String bankszamlaTulajdonosNeve;
  bool isReadOnly;
  Bankszamla();

  Bankszamla.fromJson(Map<String, dynamic> json) {
    bankszamlaSzam = json['BankszamlaSzam'];
    bankszamlaTulajdonosTipusId = json['BankszamlaTulajdonosTipusId'];
    bankszamlaTulajdonosNeve = json['BankszamlaTulajdonosNeve'];
    isReadOnly = json['IsReadOnly'];
  }
}

class Intezmeny {
  String uid;
  String rovidNev;
  List<Rendszermodulok> rendszermodulok;
  TestreszabasBeallitasok testreszabasBeallitasok;
  Intezmeny();

  Intezmeny.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
    rovidNev = json['RovidNev'];
    if (json['Rendszermodulok'] != null) {
      rendszermodulok = new List<Rendszermodulok>();
      json['Rendszermodulok'].forEach((v) {
        rendszermodulok.add(new Rendszermodulok.fromJson(v));
      });
    }
    testreszabasBeallitasok = json['TestreszabasBeallitasok'] != null
        ? new TestreszabasBeallitasok.fromJson(json['TestreszabasBeallitasok'])
        : null;
  }
}

class Rendszermodulok {
  bool isAktiv;
  String tipus;
  Rendszermodulok();

  Rendszermodulok.fromJson(Map<String, dynamic> json) {
    isAktiv = json['IsAktiv'];
    tipus = json['Tipus'];
  }
}

class TestreszabasBeallitasok {
  bool isDiakRogzithetHaziFeladatot;
  bool isTanorakTemajaMegtekinthetoEllenorzoben;
  bool isOsztalyAtlagMegjeleniteseEllenorzoben;
  int ertekelesekMegjelenitesenekKesleltetesenekMerteke;
  TestreszabasBeallitasok();

  TestreszabasBeallitasok.fromJson(Map<String, dynamic> json) {
    isDiakRogzithetHaziFeladatot = json['IsDiakRogzithetHaziFeladatot'];
    isTanorakTemajaMegtekinthetoEllenorzoben =
        json['IsTanorakTemajaMegtekinthetoEllenorzoben'];
    isOsztalyAtlagMegjeleniteseEllenorzoben =
        json['IsOsztalyAtlagMegjeleniteseEllenorzoben'];
    ertekelesekMegjelenitesenekKesleltetesenekMerteke =
        json['ErtekelesekMegjelenitesenekKesleltetesenekMerteke'];
  }
}
