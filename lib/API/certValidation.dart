import 'dart:io'
    show HttpClient, HttpOverrides, SecurityContext, X509Certificate;
import 'package:novynaplo/data/models/kretaCert.dart';
import 'package:rsa_pkcs/rsa_pkcs.dart' as rsa_pkcs;

List<KretaCert> trustedCerts = [];

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        final rsa_pkcs.RSAPKCSParser parser = rsa_pkcs.RSAPKCSParser();
        final rsa_pkcs.RSAKeyPair pair = parser.parsePEM(cert.pem);
        //* This should keep novyNaplo running even in another
        //* kréta fuckup.... No it doesn't make it any less secure than the original kréta app.
        return trustedCerts.any((element) {
          return element.subject == cert.subject &&
              element.radixModulus == pair.public.modulus.toRadixString(16) &&
              element.exponent == pair.public.publicExponent;
        });
      };
  }
}
