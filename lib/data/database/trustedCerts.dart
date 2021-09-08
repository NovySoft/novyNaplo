import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/kretaCert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;

Future<void> setTrustedCerts(List<KretaCert> trustedCertsInput) async {
  FirebaseCrashlytics.instance.log("setTrustedCerts");
  final Batch batch = globals.db.batch();
  for (KretaCert cert in trustedCertsInput) {
    KretaCert temp = cert;
    temp.date = DateTime.now().toUtc().toString();
    batch.insert(
      "TrustedCerts",
      temp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  await batch.commit();
}

Future<List<KretaCert>> getTrustedCerts() async {
  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM TrustedCerts',
  );

  List<KretaCert> outputTempList = List.generate(maps.length, (i) {
    KretaCert temp = new KretaCert.fromSqlite(maps[i]);
    return temp;
  });

  List<KretaCert> output = await deleteOldCerts(outputTempList);
  return output;
}

Future<List<KretaCert>> deleteOldCerts(List<KretaCert> trustedCerts) async {
  List<KretaCert> output = trustedCerts;

  bool deleted = trustedCerts.any((element) {
    DateTime date = DateTime.parse(element.date);
    date = date.add(Duration(days: 7));
    return date.isBefore(DateTime.now());
  });

  if (deleted || trustedCerts.length == 0) {
    if (deleted) {
      // Renew all certs
      globals.db.rawDelete("DELETE FROM TrustedCerts");
    }
    output = await RequestHandler.getKretaTrustedCerts();
  }
  return output;
}
