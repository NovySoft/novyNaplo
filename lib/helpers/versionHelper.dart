import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:novynaplo/config.dart' as config;

class NewVersion {
  String versionCode;
  String releaseNotes;
  String releaseLink;
  bool returnedAnything;
  bool isBreaking;
}

Future<NewVersion> getVersion() async {
  NewVersion output = new NewVersion();
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (config.isAppRelease) {
    if (connectivityResult == ConnectivityResult.none) {
      output.returnedAnything = false;
      return output;
    } else {
      try {
        var res = await http.get(
            'https://raw.githubusercontent.com/NovySoft/novyNaplo/master/version.json');
        if (res.statusCode != 200) {
          output.returnedAnything = false;
          return output;
        }
        var gitJson = json.decode(res.body);
        if (config.isAppPlaystoreRelease) {
          output.versionCode = gitJson['playVersion'];
          output.releaseNotes = gitJson['playNotes'];
          output.releaseLink = gitJson['playLink'];
          output.isBreaking = gitJson['isPlayBreaking'];
        } else {
          output.versionCode = gitJson['version'];
          output.releaseNotes = gitJson['releaseNotes'];
          output.releaseLink = gitJson['releaseLink'];
          output.isBreaking = gitJson['isBreaking'];
        }
        output.returnedAnything = true;
        return output;
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'getVersion');
        output.returnedAnything = false;
        return output;
      }
    }
  } else {
    output.returnedAnything = false;
    return output;
  }
}
