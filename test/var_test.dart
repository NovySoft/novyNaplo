import 'package:test/test.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/screens/login_page.dart' as login;

void main() {
  group('Variables', () {
    test('Encryption keys must be 16 chars', () {
      print(config.passKey);
      expect(config.passKey.length, 16);
    });

    test('Encryption keys must be 16 chars', () {
      print(config.userKey);
      expect(config.userKey.length, 16);
    });

    test('Encryption keys must be 16 chars', () {
      print(config.codeKey);
      expect(config.codeKey.length, 16);
    });

    test('Must have an agent', () {
      print(config.currAgent);
      expect(config.currAgent.length, greaterThanOrEqualTo(1));
    });

    test('Must have a menuLogo', () {
      print(config.menuLogo);
      expect(config.menuLogo.length, greaterThanOrEqualTo(1));
    });

    test('Must have a loading text', () {
      print(login.loadingText);
      expect(login.loadingText.length, greaterThanOrEqualTo(1));
    });


  });
}