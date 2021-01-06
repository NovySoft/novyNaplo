import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/login_page.dart' as login;
import 'package:novynaplo/global.dart' as globals;

class LoadingSpinner extends StatefulWidget {
  @override
  LoadingSpinnerState createState() => new LoadingSpinnerState();
}

class LoadingSpinnerState extends State<LoadingSpinner> {
  String loadingText = getTranslatedString("plsWait");
  static final GlobalKey<State> key = login.KeyLoaderKey.keyLoader;
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return new WillPopScope(
      onWillPop: () async => false,
      child: SimpleDialog(
        key: key,
        backgroundColor: Colors.black54,
        children: <Widget>[
          Center(
            child: Column(
              children: [
                SpinKitPouringHourglass(color: Colors.lightBlueAccent),
                SizedBox(height: 10),
                Text(
                  loadingText,
                  style: TextStyle(color: Colors.blueAccent),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
