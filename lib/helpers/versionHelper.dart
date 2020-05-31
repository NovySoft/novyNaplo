import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:in_app_update/in_app_update.dart';
import 'dart:io' show Platform;

class NewVersion {
  String versionCode;
  String releaseNotes;
  String releaseLink;
  bool returnedAnything;
  bool isBreaking;
  bool isPlayStore;
}

Future<void> getVersion() async {
  try {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (config.isAppRelease) {
      if (connectivityResult == ConnectivityResult.none) {
        return;
      } else {
        if (Platform.isAndroid) {
          AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
          if (updateInfo?.updateAvailable == true) {
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
            } else if (updateInfo?.immediateUpdateAllowed == true) {
              await InAppUpdate.performImmediateUpdate();
            }
          }
        }
      }
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'getVersion');
    return;
  }
}
