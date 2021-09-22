import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/github.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/main.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/config.dart' as config;
import 'package:url_launcher/url_launcher.dart';

class VersionHelper {
  static Future<void> checkForUpdates() async {
    bool checkForTestVersions =
        globals.prefs.getBool("checkForTestVersions") ?? false;
    GitHubReleaseInfo latestVersion = await RequestHandler.getLatestGitVer();
    GitHubReleaseInfo latestPreVersion =
        await RequestHandler.getLatestPreGitVer();

    if (checkForTestVersions) {
      if (latestVersion.tagName != config.currentAppVersionCode)
        latestVersion = latestPreVersion;
    } else if (latestPreVersion.tagName == config.currentAppVersionCode) {
      latestVersion = latestPreVersion;
    }

    // I do versioning like this: 1.major.minor+patch(+nonsense giberrish, if test version)
    if (latestVersion.tagName != config.currentAppVersionCode) {
      //Check if it is higher than current version
      String splitVlatest = latestVersion.tagName.split('V')[1];
      String splitVcurrent = config.currentAppVersionCode.split('V')[1];

      int mainVLatest = int.parse(splitVlatest.split('.')[0]);
      int majorVLatest = int.parse(splitVlatest.split('.')[1]);
      int minorVLatest = int.parse(
        splitVlatest.split('.')[2].split('+')[0],
      );
      int patchVLatest = int.parse(splitVlatest.split('+')[1]);
      String commentVLatest =
          splitVlatest.split('+').length >= 3 ? splitVlatest.split('+')[2] : "";

      print(
        "Latest server version: $mainVLatest.$majorVLatest.$minorVLatest+$patchVLatest+$commentVLatest",
      );

      int mainVCurrent = int.parse(splitVcurrent.split('.')[0]);
      int majorVCurrent = int.parse(splitVcurrent.split('.')[1]);
      int minorVCurrent = int.parse(
        splitVcurrent.split('.')[2].split('+')[0],
      );
      int patchVCurrent = int.parse(splitVcurrent.split('+')[1]);
      String commentVCurrent = splitVcurrent.split('+').length >= 3
          ? splitVcurrent.split('+')[2]
          : "";

      print(
        "Current version: $mainVCurrent.$majorVCurrent.$minorVCurrent+$patchVCurrent+$commentVCurrent",
      );

      if (patchVLatest < patchVCurrent) return;

      if (mainVLatest > mainVCurrent ||
          majorVLatest > majorVCurrent ||
          minorVLatest > minorVCurrent ||
          patchVLatest > patchVCurrent ||
          commentVLatest != commentVCurrent) {
        //There is a newer version
        print("Update available");
        showDialog<void>(
          context: NavigatorKey.navigatorKey.currentContext,
          builder: (context) {
            return AlertDialog(
              elevation: globals.darker ? 0 : 24,
              title: Text(getTranslatedString("newVersion")),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(getTranslatedString("newVersionAv")),
                    Wrap(
                      children: [
                        Text(config.currentAppVersionCode),
                        Icon(AntDesign.arrowright, size: 16),
                        Text(
                          "${latestVersion.tagName} (${latestVersion.asset.downloadCount} ${getTranslatedString('downloads')})",
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(getTranslatedString("details")),
                  onPressed: () {
                    showDialog(
                      barrierColor: Colors.black87,
                      context: NavigatorKey.navigatorKey.currentContext,
                      builder: (context) {
                        return Center(
                          child: Markdown(
                            styleSheet: MarkdownStyleSheet(
                              a: TextStyle(color: Colors.white),
                              p: TextStyle(color: Colors.white),
                              h1: TextStyle(color: Colors.white),
                              h2: TextStyle(color: Colors.white),
                              h3: TextStyle(color: Colors.white),
                              h4: TextStyle(color: Colors.white),
                              h5: TextStyle(color: Colors.white),
                              h6: TextStyle(color: Colors.white),
                              listBullet: TextStyle(color: Colors.white),
                              em: TextStyle(color: Colors.white),
                              strong: TextStyle(color: Colors.white),
                              blockquote: TextStyle(color: Colors.white),
                            ),
                            onTapLink: (text, url, title) async {
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                FirebaseAnalytics().logEvent(
                                  name: "LinkFail",
                                  parameters: {"link": url},
                                );
                                throw 'Could not launch $url';
                              }
                            },
                            data: latestVersion.releaseNotes,
                          ),
                        );
                      },
                    );
                  },
                ),
                TextButton(
                  child: Text(getTranslatedString("update")),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    GlobalKey<State> _dialogKey = GlobalKey<State>();
                    showDialog(
                      context: NavigatorKey.navigatorKey.currentContext,
                      barrierDismissible: false,
                      builder: (context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: SimpleDialog(
                            key: _dialogKey,
                            elevation: globals.darker ? 0 : 24,
                            children: [
                              SpinKitPouringHourGlass(
                                color: Colors.lightBlueAccent,
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: Text(
                                  "${getTranslatedString('updating')}...",
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    await RequestHandler.downloadFile(
                      url: latestVersion.asset.downloadUrl,
                      filename: "novynaplo.apk",
                      open: true,
                      reDownload: true,
                    );

                    if (_dialogKey.currentState.mounted)
                      Navigator.of(
                        _dialogKey.currentContext,
                        rootNavigator: true,
                      ).pop();
                  },
                ),
                TextButton(
                  child: Text("F-Droid"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await launch(config.fdroidUrl);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
