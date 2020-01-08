import 'package:novynaplo/config.dart' as config;
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewVersion{
  String versionCode;
  String releaseNotes;
  String releaseLink;
  bool returnedAnything;
  bool isBreaking;
}

Future<NewVersion> getVersion() async {
  NewVersion output = new NewVersion();
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    output.returnedAnything = false;
    return output;
  } else {
    try {
      var res = await http.get(
          'https://raw.githubusercontent.com/NovySoft/novyNaplo/master/version.json');
      if (res.statusCode != 200){
        output.returnedAnything = false;
        return output;
      } 
      var gitJson = json.decode(res.body);
      output.versionCode = gitJson['version'];
      output.releaseNotes = gitJson['releaseNotes'];
      output.releaseLink = gitJson['releaseLink'];
      output.isBreaking = gitJson['isBreaking'];
      output.returnedAnything = true;
      return output;
    } catch (exception) {
      output.returnedAnything = false;
      return output;
    }
    output.returnedAnything = false;
    return output;
  }
}
