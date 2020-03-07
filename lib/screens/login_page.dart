import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:url_launcher/url_launcher.dart';

TextEditingController codeController = TextEditingController();
TextEditingController userController = TextEditingController();
TextEditingController passController = TextEditingController();
var status = "No status";
var i = 0;
var agent = config.currAgent;
var response, token, dJson, myDialogState;
String selectedSchoolCode;
int markCount, avarageCount, noticesCount = 0;
bool gotToken;
bool isPressed = true;
bool newVersion = false;
bool hasPrefs = false;
bool isError = false;
bool newUser = true;
bool listAvailable = true;
final GlobalKey<State> keyLoader = new GlobalKey<State>();
final FocusNode _passFocus = FocusNode();
final FocusNode _codeFocus = FocusNode();
final FocusNode _userFocus = FocusNode();
String loadingText = "Kérlek várj...";
var searchList = [];
var schoolList;
bool adsEnabled = true;

var passKey = encrypt.Key.fromUtf8(config.passKey);
var codeKey = encrypt.Key.fromUtf8(config.codeKey);
var userKey = encrypt.Key.fromUtf8(config.userKey);
final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void onLoad(var context) async {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return SpinnerDialog();
        });
    await sleep1();
    NewVersion newVerDetails = await getVersion();
    if (newVerDetails.returnedAnything) {
      if (config.currentAppVersionCode != newVerDetails.versionCode) {
        await _newVersionAlert(
            context,
            newVerDetails.versionCode,
            newVerDetails.releaseNotes,
            newVerDetails.isBreaking,
            newVerDetails.releaseLink);
      }
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("code") != null) {
      if (prefs.getBool("ads")) {
        adBanner.load();
        adBanner.show(
          anchorType: AnchorType.bottom,
        );
        adsEnabled = true;
      } else {
        adsEnabled = false;
      }
      newUser = false;
      FirebaseAnalytics().logEvent(name: "login");
      hasPrefs = true;
      try {
        final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
        String decryptedCode =
            codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
        String decryptedUser =
            userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
        String decryptedPass =
            userEncrypter.decrypt64(prefs.getString("password"), iv: iv);
        codeController.text = decryptedCode;
        userController.text = decryptedUser;
        passController.text = decryptedPass;
      } on PlatformException catch (e) {
        isError = true;
        _ackAlert(context, e.toString());
      } on NoSuchMethodError catch (e) {
        isError = true;
        _ackAlert(context, e.toString());
      }
      if (newVersion == false) {
        auth(context, "onLoad");
      }
    } else {
      try {
        schoolList = await NetworkHelper().getSchoolList();
        if (schoolList == "TIMEOUT") {
          listAvailable = false;
          await _timeoutAlert(context);
          try {
            Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
          } catch (e) {
            isError = true;
            _ackAlert(context, e.toString());
          }
        } else if (schoolList is int) {
          listAvailable = false;
          await _timeoutAlert(context);
          try {
            Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
          } catch (e) {
            isError = true;
            _ackAlert(context, e.toString());
          }
        } else {
          for (var n in schoolList) {
            searchList.add(n);
          }
          try {
            Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
          } catch (e) {
            isError = true;
            _ackAlert(context, e.toString());
          }
        }
      } catch (e) {
        isError = true;
        _ackAlert(context, e.toString());
      }
    }
    isPressed = false;
  }

  void auth(var context, caller) async {
    newVersion = false;
    if (caller != "onLoad") {
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return SpinnerDialog();
          });
    }
    //Not showing quickly enough
    await sleep1(); //So sleep for a second TODO FIX THIS
    if (await NetworkHelper().isNetworkAvailable() == ConnectivityResult.none) {
      status = "No internet connection was detected";
    } else {
      String code = codeController.text;
      String user = userController.text;
      String pass = passController.text;
      status = await NetworkHelper().getToken(code, user, pass);
      if (status == "OK") {
        await NetworkHelper().getStudentInfo(token, code);
      }
    }
    try {
      Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
    } catch (e) {
      isError = true;
      _ackAlert(context, e.toString());
    }

    if (status == "OK") {
      try {
        save(context, "auth");
      } on PlatformException catch (e) {
        print(e.message);
        isError = true;
        _ackAlert(context, e.message);
      }
    } else {
      _ackAlert(context, status);
    }
    isPressed = false;
    if (caller == "_ackAlert") {
      Navigator.of(context).pop();
    }
  }

  void save(var context, caller) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Inputs
    String code = codeController.text;
    String user = userController.text;
    String pass = passController.text;
    //Encryption
    final iv = encrypt.IV.fromLength(16);
    prefs.setString("iv", iv.base64);
    try {
      String encryptedPass = passEncrypter.encrypt(pass, iv: iv).base64;
      String encryptedUser = userEncrypter.encrypt(user, iv: iv).base64;
      String encryptedCode = codeEncrypter.encrypt(code, iv: iv).base64;
      prefs.setString("password", encryptedPass);
      prefs.setString("code", encryptedCode);
      prefs.setString("user", encryptedUser);
      FirebaseAnalytics().setUserProperty(name: "School", value: code);
    } on PlatformException catch (e) {
      isError = true;
      _ackAlert(context, e.message);
    }

    try {
      if (newUser) {
        Navigator.pushReplacementNamed(context, SettingsTab.tag);
      } else {
        Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
      }
    } on PlatformException catch (e) {
      isError = true;
      _ackAlert(context, e.message);
    }
    if (caller == "_ackAlert") {
      Navigator.of(context).pop();
    }
    //String decryptedString = await Cipher2.decryptAesCbc128Padding7(encryptedString, key, iv);
    /*
  print("prefs:");
  print(prefs.getString("password"));
  print(prefs.getString("code"));
  print(prefs.getString("user"));
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

  @override
  Widget build(BuildContext context) {
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
        hintText: 'Iskola azonosító',
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
        hintText: 'Felhasználónév',
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
        hintText: 'Jelszó',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
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
        child: Text('Bejelentkezés', style: TextStyle(color: Colors.black)),
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
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Státusz'),
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

  Future<void> _newVersionAlert(BuildContext context, String version,
      String notes, bool isBreaking, String link) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Új verzió: $version"),
          content: SingleChildScrollView(
            child:
                Column(children: <Widget>[Text("Megjegyzések:"), Text(notes)]),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                if (newVersion == true && hasPrefs) {
                  auth(context, "_ackAlert");
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            FlatButton(
              child: Text('Frissítés'),
              onPressed: () async {
                if (await canLaunch(link)) {
                  await launch(link);
                } else {
                  FirebaseAnalytics().logEvent(name: "LinkFail");
                  throw 'Could not launch $link';
                }
                Navigator.of(context).pop();
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
          title: Text("Hiba: Kérés timeout"),
          content: SingleChildScrollView(
            child: Column(children: <Widget>[
              Text("Hiba:"),
              Text("A kérésünkre nem kaptunk választ 10 másodperc után sem!"),
              Text(
                "Manuális kód megadás szükséges!",
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
    return new SimpleDialog(
      title: new Text("Iskola választó"),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        new Container(
          child: new TextField(
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
