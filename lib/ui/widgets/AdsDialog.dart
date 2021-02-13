import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/helpers/ui/adHelper.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

class AdsDialog extends StatefulWidget {
  @override
  _AdsDialogState createState() => new _AdsDialogState();
}

class _AdsDialogState extends State<AdsDialog> {
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text(getTranslatedString("ads")),
      content: Text(
        getTranslatedString("turnOnAds"),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () async {
            globals.adsEnabled = true;
            adBanner.load();
            adBanner.show(
              anchorType: AnchorType.bottom,
            );
            Navigator.of(context).pop();
            showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) => ThxForSupporting(),
            );
          },
        ),
      ],
    );
  }
}

class AdsDialogNewUser extends StatefulWidget {
  @override
  _AdsDialogNewUserState createState() => new _AdsDialogNewUserState();
}

class _AdsDialogNewUserState extends State<AdsDialogNewUser> {
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text(getTranslatedString("enableAds")),
      content: Text(
        getTranslatedString("turnOnAdsNewUser"),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(getTranslatedString("yes")),
          onPressed: () async {
            globals.adsEnabled = true;
            await globals.prefs.setBool("ads", true);
            adBanner.load();
            adBanner.show(
              anchorType: AnchorType.bottom,
            );
            Navigator.of(context).pop();
            showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) => ThxForSupporting(),
            );
          },
        ),
        FlatButton(
          child: Text(
            getTranslatedString("no"),
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            globals.adsEnabled = false;
            await globals.prefs.setBool("ads", false);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ThxForSupporting extends StatefulWidget {
  @override
  _ThxForSupportingState createState() => new _ThxForSupportingState();
}

class _ThxForSupportingState extends State<ThxForSupporting> {
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text(getTranslatedString("thxForSupporting")),
      content: Icon(
        MdiIcons.accountHeart,
        color: Colors.red,
        size: 60,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
