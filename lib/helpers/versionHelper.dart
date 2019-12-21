import 'package:package_info/package_info.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    return "false";
  } else {
    try {
      var res = await http.get(
          'https://raw.githubusercontent.com/NovySoft/novyNaplo/master/version.json');
      if (res.statusCode != 200) return "false";
      var gitVersion = json.decode(res.body);
      gitVersion = gitVersion['version'];
      if (version != gitVersion) {
        return gitVersion;
      }
    } catch (exception) {
      return "false";
    }
    return "false";
  }
}
