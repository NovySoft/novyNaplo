import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/school.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/ui/adHelper.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/main.dart' as main;
import 'package:novynaplo/ui/screens/settings/settings_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/LoadingSpinner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:firebase_admob/firebase_admob.dart';

//FIXME: Future async functions and await
//FIXME REWRITE EVERYTHING HERE
TextEditingController codeController = TextEditingController();
TextEditingController userController = TextEditingController();
TextEditingController passController = TextEditingController();
var status = "No status";
var i = 0;
var agent = config.userAgent;
String selectedSchoolCode;
bool gotToken;
bool isPressed = true;
bool newVersion = false;
bool hasPrefs = false;
bool isError = false;
bool listAvailable = true;
final FocusNode _passFocus = FocusNode();
final FocusNode _codeFocus = FocusNode();
final FocusNode _userFocus = FocusNode();
var searchList = [];
var schoolList;
var passKey = encrypt.Key.fromUtf8(config.passKey);
var codeKey = encrypt.Key.fromUtf8(config.codeKey);
var userKey = encrypt.Key.fromUtf8(config.userKey);
final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));

class KeyLoaderKey {
  static final keyLoader = new GlobalKey<State>();
}

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void onLoad(var context) async {
    FirebaseCrashlytics.instance.log("Shown login screen");
    FirebaseCrashlytics.instance
        .setCustomKey("Version", config.currentAppVersionCode);
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return LoadingSpinner();
        });
    await delay(1000);
    if (globals.verCheckOnStart) {
      await getVersion();
    }
    if (globals.prefs.getString("code") != null &&
        globals.prefs.getBool("ads") != null) {
      FirebaseCrashlytics.instance
          .setCustomKey("Ads", globals.prefs.getBool("ads"));
      if (globals.prefs.getBool("ads")) {
        adBanner.load();
        adBanner.show(
          anchorType: AnchorType.bottom,
        );
        globals.adModifier = 1;
        globals.adsEnabled = true;
      } else {
        globals.adModifier = 0;
        globals.adsEnabled = false;
      }
      main.isNew = false;
      FirebaseAnalytics().logEvent(name: "login");
      hasPrefs = true;
      try {
        for (var i = 0; i < 2; i++) {
          final iv = encrypt.IV.fromBase64(globals.prefs.getString("iv"));
          String decryptedCode =
              codeEncrypter.decrypt64(globals.prefs.getString("code"), iv: iv);
          String decryptedUser =
              userEncrypter.decrypt64(globals.prefs.getString("user"), iv: iv);
          String decryptedPass = userEncrypter
              .decrypt64(globals.prefs.getString("password"), iv: iv);
          codeController.text = decryptedCode;
          userController.text = decryptedUser;
          passController.text = decryptedPass;
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s, reason: 'onLoad-login');
        isError = true;
        _ackAlert(context, e.toString());
      }
      if (newVersion == false) {
        auth(context, "onLoad");
      }
    } else {
      try {
        schoolList = await RequestHandler.getSchoolList();
        if (schoolList == "TIMEOUT") {
          listAvailable = false;
          await _timeoutAlert(context);
          try {
            Navigator.of(KeyLoaderKey.keyLoader.currentContext,
                    rootNavigator: true)
                .pop();
          } catch (e, s) {
            FirebaseCrashlytics.instance
                .recordError(e, s, reason: 'navigator-login');
            isError = true;
            _ackAlert(context, e.toString());
          }
        } else if (schoolList is int) {
          listAvailable = false;
          await _timeoutAlert(context);
          try {
            Navigator.of(KeyLoaderKey.keyLoader.currentContext,
                    rootNavigator: true)
                .pop();
          } catch (e, s) {
            FirebaseCrashlytics.instance
                .recordError(e, s, reason: 'navigator-login');
            isError = true;
            _ackAlert(context, e.toString());
          }
        } else {
          for (var n in schoolList) {
            searchList.add(n);
          }
          try {
            Navigator.of(KeyLoaderKey.keyLoader.currentContext,
                    rootNavigator: true)
                .pop();
          } catch (e, s) {
            FirebaseCrashlytics.instance
                .recordError(e, s, reason: 'navigator-login');
            isError = true;
            _ackAlert(context, e.toString());
          }
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'navigator-login');
        isError = true;
        _ackAlert(context, e.toString());
      }
    }
    isPressed = false;
  }

  //TODO: Only check credentials and do the fetching on loading page.
  void auth(var context, caller) async {
    try {
      globals.prefs.setBool("isNew", false);
      globals.adsEnabled = false;
      globals.prefs.setBool("ads", false);
      globals.adModifier = 0;
      newVersion = false;
      if (caller != "onLoad") {
        showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return LoadingSpinner();
            });
      }
      //Not showing quickly enough
      await delay(1000); //So sleep for a second
      if (await NetworkHelper().isNetworkAvailable() ==
          ConnectivityResult.none) {
        status = "No internet connection was detected";
      } else {
        globals.userDetails.school = codeController.text;
        globals.userDetails.username = userController.text;
        globals.userDetails.password = passController.text;
        status = await RequestHandler.login(globals.userDetails);
        if (status == "OK") {
          await NetworkHelper().getStudentInfo(
              globals.userDetails.token, globals.userDetails.school);
        }
      }
      Navigator.of(KeyLoaderKey.keyLoader.currentContext, rootNavigator: true)
          .pop();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'auth-login');
      isError = true;
      _ackAlert(context, e.toString());
    }

    if (status == "OK") {
      try {
        save(context, "auth");
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s, reason: 'save-login');
        isError = true;
        _ackAlert(context, e.message);
      }
    } else {
      if (status != null) _ackAlert(context, status);
      if (status == null) _ackAlert(context, getTranslatedString("unkError"));
    }
    isPressed = false;
    if (caller == "_ackAlert") {
      Navigator.of(context).pop();
    }
  }

  Future<void> save(var context, caller) async {
    //Inputs
    String code = codeController.text;
    String user = userController.text;
    String pass = passController.text;
    //Encryption
    final iv = encrypt.IV.fromLength(16);
    globals.prefs.setString("iv", iv.base64);
    try {
      String encryptedPass = passEncrypter.encrypt(pass, iv: iv).base64;
      String encryptedUser = userEncrypter.encrypt(user, iv: iv).base64;
      String encryptedCode = codeEncrypter.encrypt(code, iv: iv).base64;
      globals.prefs.setString("password", encryptedPass);
      globals.prefs.setString("code", encryptedCode);
      globals.prefs.setString("user", encryptedUser);
      FirebaseAnalytics().setUserProperty(
          name: "Version", value: config.currentAppVersionCode);
      FirebaseCrashlytics.instance
          .setCustomKey("Version", config.currentAppVersionCode);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'encrypt-login');
      isError = true;
      _ackAlert(context, e.message);
    }

    try {
      if (main.isNew) {
        if (globals.adsEnabled == null) {
          globals.adsEnabled = false;
          globals.adModifier = 0;
        }
        Navigator.pushReplacementNamed(context, SettingsTab.tag);
      } else {
        if (globals.adsEnabled == null) {
          globals.adsEnabled = false;
          globals.adModifier = 0;
        }
        Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'navigatorReplacement-login');
      isError = true;
      _ackAlert(context, e.message);
    }
    if (caller == "_ackAlert") {
      Navigator.of(context).pop();
    }
    //String decryptedString = await Cipher2.decryptAesCbc128Padding7(encryptedString, key, iv);
    /*
  print("prefs:");
  print(globals.prefs.getString("password"));
  print(globals.prefs.getString("code"));
  print(globals.prefs.getString("user"));
  */
  }

  void showSelectDialog() {
    setState(() {
      showDialog<School>(
          context: context,
          builder: (BuildContext context) {
            return new SchoolSelect();
          }).then((dynamic) {
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: config.adMob);
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad(context));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setNewUserPrefs() async {
    globals.prefs.setBool("isNew", true);
    globals.prefs.setBool("isNotNew", true);
  }

  @override
  Widget build(BuildContext context) {
    setNewUserPrefs();
    globals.globalContext = context;
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 75.0,
          child: Image.asset('assets/home.png')),
    );

    final code = TextFormField(
      focusNode: _codeFocus,
      controller: codeController,
      onTap: () {
        if (listAvailable) showSelectDialog();
      },
      onChanged: (String input) {
        if (listAvailable) showSelectDialog();
      },
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: getTranslatedString("schId"),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onFieldSubmitted: (String input) {
        _codeFocus.unfocus();
        FocusScope.of(context).requestFocus(_userFocus);
      },
    );

    final user = TextFormField(
      focusNode: _userFocus,
      controller: userController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: getTranslatedString("username"),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (String input) {
        _userFocus.unfocus();
        FocusScope.of(context).requestFocus(_passFocus);
      },
    );

    final password = TextFormField(
      focusNode: _passFocus,
      controller: passController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: getTranslatedString("password"),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (term) {
        _passFocus.unfocus();
        if (!isPressed) {
          isPressed = true;
          auth(context, "loginButton");
          FirebaseAnalytics().logEvent(name: "sign_up");
        }
      },
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          if (!isPressed) {
            isPressed = true;
            auth(context, "loginButton");
            FirebaseAnalytics().logEvent(name: "sign_up");
          }
          /*
          Navigator.of(context).pushNamed(HomePage.tag);
          runApp(HomePage(post: fetchPost()));
          */
        },
        padding: EdgeInsets.all(12),
        child: Text(getTranslatedString("login"),
            style: TextStyle(color: Colors.black)),
      ),
    );

    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            code,
            SizedBox(height: 8.0),
            user,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
          ],
        ),
      ),
    );
  }

  Future<void> _ackAlert(BuildContext context, String content) async {
    if (content == null) content = getTranslatedString("unkError");
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslatedString("status")),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                if (isError) {
                  Navigator.of(context).pop();
                } else if (newVersion == true && hasPrefs) {
                  auth(context, "_ackAlert");
                } else if (status == "OK") {
                  save(context, "_ackAlert");
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _timeoutAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslatedString("timeoutErr")),
          content: SingleChildScrollView(
            child: Column(children: <Widget>[
              Text("${getTranslatedString("err")}:"),
              Text(getTranslatedString("noAns10")),
              Text(
                getTranslatedString("manCode"),
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ]),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SchoolSelect extends StatefulWidget {
  @override
  _SchoolSelectState createState() => new _SchoolSelectState();
}

class _SchoolSelectState extends State<SchoolSelect> {
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return new SimpleDialog(
      title: new Text(getTranslatedString("schSelector")),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        new Container(
          child: new TextField(
              keyboardType: TextInputType.text,
              maxLines: 1,
              autofocus: true,
              onChanged: (String search) {
                setState(() {
                  updateSearch(search);
                });
              }),
          margin: new EdgeInsets.all(10.0),
        ),
        new Container(
          child: searchList != null
              ? new ListView.builder(
                  itemBuilder: _itemBuilder,
                  itemCount: searchList.length,
                )
              : new Container(),
          width: 320.0,
          height: 400.0,
        )
      ],
    );
  }

  void updateSearch(String searchText) {
    setState(() {
      searchList = [];
      for (var n in schoolList) {
        searchList.add(n);
      }
    });

    if (searchText != "") {
      setState(() {
        searchList.removeWhere((dynamic element) => !element.name
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase()));
      });
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return ListTile(
      title: new Text(searchList[index].name),
      subtitle: new Text(searchList[index].code),
      onTap: () {
        setState(() {
          selectedSchoolCode = searchList[index].code;
          codeController.text = selectedSchoolCode;
          Navigator.pop(context);
        });
      },
    );
  }
}
