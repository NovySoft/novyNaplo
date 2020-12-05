import 'package:novynaplo/data/models/user.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;

Future<User> decryptUserDetails() async {
  String decryptedPass, decryptedUser, decryptedCode;
  final iv = encrypt.IV.fromBase64(globals.prefs.getString("iv"));
  var passKey = encrypt.Key.fromUtf8(config.passKey);
  var codeKey = encrypt.Key.fromUtf8(config.codeKey);
  var userKey = encrypt.Key.fromUtf8(config.userKey);
  final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
  final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
  final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
  decryptedCode = codeEncrypter.decrypt64(
    globals.prefs.getString("code"),
    iv: iv,
  );
  decryptedUser = userEncrypter.decrypt64(
    globals.prefs.getString("user"),
    iv: iv,
  );
  decryptedPass = passEncrypter.decrypt64(
    globals.prefs.getString("password"),
    iv: iv,
  );
  globals.userDetails.username = decryptedUser;
  globals.userDetails.password = decryptedPass;
  globals.userDetails.school = decryptedCode;
  return globals.userDetails;
}
