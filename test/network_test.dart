import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:novynaplo/config.dart' as config;
import 'package:mockito/mockito.dart';
import 'dart:convert';

class MockClient extends Mock implements http.Client {}

void main() {
  group('Kreta response test', () {
    test('Does kreta send response?', () async {
      bool decodeSucceeded = false;
      String agent = config.currAgent;
      String code = "klik035046001";
      String user = "NotActualUser";
      String pass = "NotActualPassword";
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        'User-Agent': '$agent',
      };

      var data =
          'institute_code=$code&userName=$user&password=$pass&grant_type=password&client_id=919e0c1c-76a2-4646-a2fb-7085bbbf3c56';
      var response = await http.post(
          'https://$code.e-kreta.hu/idp/api/v1/Token',
          headers: headers,
          body: data);

      print(response.body);
      
      try {
        var x = json.decode(response.body) as Map<String, dynamic>;
        decodeSucceeded = true;
      } on FormatException catch (e) {
        print('The provided string is not valid JSON');
      }

      expect(decodeSucceeded, true);
    });
  });
}
