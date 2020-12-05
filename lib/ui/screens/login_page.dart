import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/helpers/ui/animations/circularProgressButton.dart'
    as progressButton;
import 'package:novynaplo/helpers/ui/animations/shake_view.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';

class KeyLoaderKey {
  static final keyLoader = new GlobalKey<State>();
}

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final FocusNode _codeFocus = FocusNode();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  ShakeController _shakeController;
  bool isPressed = false;
  bool _isWrong = false;
  bool _obscureText = true;

  @override
  void initState() {
    _shakeController = ShakeController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    super.initState();
  }

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void setNewUserPrefs() async {
    globals.prefs.setBool("isNew", true);
    globals.prefs.setBool("isNotNew", true);
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 75.0,
          child: Image.asset('assets/home.png')),
    );

    final codeInput = TextFormField(
      focusNode: _codeFocus,
      controller: _codeController,
      //TODO show list
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: getTranslatedString("schId"),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
      onFieldSubmitted: (String input) {
        _codeFocus.unfocus();
        FocusScope.of(context).requestFocus(_userFocus);
      },
    );

    final usernameInput = ShakeView(
      controller: _shakeController,
      child: TextFormField(
        focusNode: _userFocus,
        controller: userController,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: getTranslatedString("username"),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: _isWrong ? Colors.red : Colors.grey),
          ),
        ),
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (String input) {
          _userFocus.unfocus();
          FocusScope.of(context).requestFocus(_passFocus);
        },
      ),
    );

    final passwordInput = ShakeView(
      controller: _shakeController,
      child: TextFormField(
        focusNode: _passFocus,
        controller: passController,
        autofocus: false,
        obscureText: _obscureText,
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () {
              togglePasswordVisibility();
            },
            child: Icon(_obscureText ? MdiIcons.eyeOff : MdiIcons.eye),
          ),
          hintText: getTranslatedString("password"),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: _isWrong ? Colors.red : Colors.grey),
          ),
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (term) {
          _passFocus.unfocus();
          FirebaseAnalytics().logEvent(name: "sign_up");
        },
      ),
    );

    final loginButton = progressButton.CircularProgressButton(
      backgroundColor: Theme.of(context).primaryColor,
      progressIndicatorColor: Colors.blue,
      width: MediaQuery.of(context).size.width,
      height: 45,
      borderRadius: 24,
      fadeDurationInMilliSecond: 500,
      text: getTranslatedString("login"),
      fontSize: 35,
      onTap: (reset) async {
        //Fixme make actual logic here
        if (!isPressed) {
          isPressed = true;
          reset();
          await Future.delayed(Duration(seconds: 3));
          reset();
          setState(() {
            _isWrong = true;
          });
          _shakeController.shake();
        }
      },
    );

    return Scaffold(
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48),
            codeInput,
            SizedBox(height: 8.0),
            usernameInput,
            SizedBox(height: 8.0),
            passwordInput,
            SizedBox(height: 24.0),
            Center(
              child: loginButton,
            ),
          ],
        ),
      ),
    );
  }
}
