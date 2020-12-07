import 'package:novynaplo/data/models/user.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;

User decryptUserDetails(User input) {
  String decryptedPass, decryptedUser, decryptedCode;
  final iv = encrypt.IV.fromBase64(input.iv);
  var passKey = encrypt.Key.fromUtf8(config.passKey);
  var codeKey = encrypt.Key.fromUtf8(config.codeKey);
  var userKey = encrypt.Key.fromUtf8(config.userKey);
  final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
  final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
  final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
  decryptedCode = codeEncrypter.decrypt64(
    input.school,
    iv: iv,
  );
  decryptedUser = userEncrypter.decrypt64(
    input.username,
    iv: iv,
  );
  decryptedPass = passEncrypter.decrypt64(
    input.password,
    iv: iv,
  );
  return User(
    current: input.current,
    token: input.token,
    id: input.id,
    iv: iv.base64,
    school: decryptedCode,
    username: decryptedUser,
    password: decryptedPass,
  );
}
