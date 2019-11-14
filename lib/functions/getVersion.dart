import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getVersion() async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  try{
    var res = await http.get('https://raw.githubusercontent.com/Legolaszstudio/novynotifier/master/version.json');
    if (res.statusCode != 200) return "false";
    var gitVersion = json.decode(res.body);
    gitVersion = gitVersion['version'];
    if(version != gitVersion){
      return gitVersion;
    }
  }on Error{
    return "false";
  }
  return "false";
}