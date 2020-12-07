import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/data/models/user.dart';
import 'package:novynaplo/global.dart' as globals;

Future<User> encryptUserDetails(User user) async {
  encrypt.IV iv = encrypt.IV.fromLength(16);
  var passKey = encrypt.Key.fromUtf8(config.passKey);
  var codeKey = encrypt.Key.fromUtf8(config.codeKey);
  var userKey = encrypt.Key.fromUtf8(config.userKey);
  final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
  final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
  final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
  String encryptedPass = passEncrypter
      .encrypt(
        user.password,
        iv: iv,
      )
      .base64;
  String encryptedUser = userEncrypter
      .encrypt(
        user.username,
        iv: iv,
      )
      .base64;
  String encryptedCode = codeEncrypter
      .encrypt(
        user.school,
        iv: iv,
      )
      .base64;
  return User(
    iv: iv.base64,
    school: encryptedCode,
    username: encryptedUser,
    password: encryptedPass,
  );
}
