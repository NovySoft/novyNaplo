import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/global.dart' as globals;
import 'package:in_app_update/in_app_update.dart';
import 'dart:io' show Platform;
import 'package:novynaplo/screens/settings_tab.dart' as settings;

class NewVersion {
  String versionCode;
  String releaseNotes;
  String releaseLink;
  bool returnedAnything;
  bool isBreaking;
  bool isPlayStore;
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
        var gitJson;
        if (res.statusCode != 200) {
          output.returnedAnything = false;
        } else {
          output.returnedAnything = true;
          globals.versionInfoJson = res.body;
          gitJson = json.decode(res.body);
          settings.latestGithub = gitJson['version'];
          settings.latestPlayStore = gitJson['playVersion'];
        }
        //TODO refactor this nested nightmare
        if (config.isAppPlaystoreRelease && Platform.isAndroid) {
          output.isPlayStore = true;
          AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
          if (output.returnedAnything) {
            if (updateInfo?.updateAvailable == true) {
              if (gitJson["isPlayBreaking"]) {
                if (updateInfo?.immediateUpdateAllowed == true) {
                  await InAppUpdate.performImmediateUpdate();
                }
              } else {
                if (updateInfo?.flexibleUpdateAllowed == true) {
                  bool errored = false;
                  try {
                    await InAppUpdate.startFlexibleUpdate();
                  } catch (e) {
                    errored = true;
                  }
                  if (errored == false) {
                    await InAppUpdate.completeFlexibleUpdate();
                  }
                }
              }
            }
          }
        } else {
          if (output.returnedAnything == false) {
            return output;
          }
          output.isPlayStore = false;
          output.versionCode = gitJson['version'];
          output.releaseNotes = gitJson['releaseNotes'];
          output.releaseLink = gitJson['releaseLink'];
          output.isBreaking = gitJson['isBreaking'];
        }
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
