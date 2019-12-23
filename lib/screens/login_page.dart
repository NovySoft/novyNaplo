import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/screens/notices_tab.dart';

TextEditingController codeController =
    TextEditingController(text: "klik035046001");
TextEditingController userController = TextEditingController();
TextEditingController passController = TextEditingController();
var status = "No status";
var i = 0;
var agent = config.currAgent;
var response, token, dJson;
int markCount,avarageCount,noticesCount = 0;
bool gotToken;
bool isPressed = false;
bool newVersion = false;
bool hasPrefs = false;
bool isError = false;
final GlobalKey<State> _keyLoader = new GlobalKey<State>();
String loadingText = "Kérlek várj...";

var passKey = encrypt.Key.fromUtf8(config.passKey);
var codeKey = encrypt.Key.fromUtf8(config.codeKey);
var userKey = encrypt.Key.fromUtf8(config.userKey);
final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));

void onLoad(var context) async {
  if (await getVersion() != "false") {
    String s = await getVersion();
    s = "New version: $s";
    newVersion = true;
    AlertBox()._ackAlert(context, s);
  }
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString("code") != null) {
    FirebaseAnalytics().logEvent(name: "login");
    hasPrefs = true;
    try{
      final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
      String decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"),iv: iv);
      String decryptedUser = userEncrypter.decrypt64(prefs.getString("user"),iv: iv);
      String decryptedPass = userEncrypter.decrypt64(prefs.getString("password"),iv: iv);
      codeController.text = decryptedCode;
      userController.text = decryptedUser;
      passController.text = decryptedPass;
    }on PlatformException catch(e){
      isError = true;
      AlertBox()._ackAlert(context, e.toString());
    }on NoSuchMethodError catch(e){
      isError = true;
      AlertBox()._ackAlert(context, e.toString());
    }
    if(newVersion == false){
      auth(context,"onLoad");
    }
  }
}

void auth(var context,caller) async {
  newVersion = false;
  Dialogs.showLoadingDialog(context, _keyLoader); //Not showing quickly enough
  await sleep1(); //So sleep for a second
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
  try{
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  } on NoSuchMethodError catch (e){
    isError = true;
    AlertBox()._ackAlert(context, e.toString());
  }
  
  if (status == "OK") {
    try {
      save(context,"auth");
    } on PlatformException catch (e) {
      print(e.message);
      isError = true;
      AlertBox()._ackAlert(context, e.message);
    }
  } else {
    AlertBox()._ackAlert(context, status);
  }
  isPressed = false;
  if(caller == "_ackAlert"){
    Navigator.of(context).pop();
  }
}

void save(var context,caller) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  //Inputs
  String code = codeController.text;
  String user = userController.text;
  String pass = passController.text;
  //Encryption
  final iv = encrypt.IV.fromLength(16);
  prefs.setString("iv", iv.base64);
  try {
    String encryptedPass =
        passEncrypter.encrypt(pass,iv: iv).base64;
    String encryptedUser =
        userEncrypter.encrypt(user,iv: iv).base64;
    String encryptedCode =
        codeEncrypter.encrypt(code,iv: iv).base64;
    prefs.setString("password", encryptedPass);
    prefs.setString("code", encryptedCode);
    prefs.setString("user", encryptedUser);
    FirebaseAnalytics().setUserProperty(name: "School",value: code);
  } on PlatformException catch (e) {
    isError = true;
    AlertBox()._ackAlert(context, e.message);
  }

  try {
    await Navigator.pushNamed(context, MarksTab.tag);
  } on PlatformException catch (e) {
    isError = true;
    AlertBox()._ackAlert(context, e.message);
  }
  if(caller == "_ackAlert"){
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

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    onLoad(context);
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
        backgroundColor: Colors.black,
        radius: 55.0,
        child: Image.asset('assets/home.png'),
      ),
    );

    final code = TextFormField(
      controller: codeController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(hintText: 'Iskola azonosító',contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),),
    );

    final user = TextFormField(
      controller: userController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(hintText: 'Felhasználónév',contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),),
    );

    final password = TextFormField(
      controller: passController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(hintText: 'Jelszó',contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),),
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
            auth(context,"loginButton");
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
}

class AlertBox{
  Future<void> _ackAlert(BuildContext context, String content) async{
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
              if(isError){
                Navigator.of(context).pop();
              }else if(newVersion == true && hasPrefs){
                auth(context,"_ackAlert");
              }else if (status == "OK") {
                save(context,"_ackAlert");
              }else{
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
}