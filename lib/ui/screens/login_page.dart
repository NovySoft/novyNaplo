import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/getSql.dart';
import 'package:novynaplo/data/database/insertSql.dart';
import 'package:novynaplo/data/models/school.dart';
import 'package:novynaplo/data/models/user.dart';
import 'package:novynaplo/helpers/data/encryptionHelper.dart';
import 'package:novynaplo/helpers/ui/animations/circularProgressButton.dart'
    as progressButton;
import 'package:novynaplo/helpers/ui/animations/shake_view.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/SchoolSearchList.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksTab;

Function resetButtonAnimation;
var schoolList = [];
School selectedSchool = School();
final TextEditingController schoolController = TextEditingController();

class KeyLoaderKey {
  static final keyLoader = new GlobalKey<State>();
}

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final FocusNode _codeFocus = FocusNode();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  ShakeController _userShakeController;
  ShakeController _schoolShakeController;
  bool isPressed = false;
  bool _isWrongUser = false;
  bool _obscureText = true;
  bool _isWrongSchool = false;
  User tempUser = User();
  bool isFirstUser = false;

  void showSelectDialog() {
    setState(() {
      showDialog<School>(
          context: context,
          builder: (BuildContext context) {
            return new SchoolSearchList();
          }).then((dynamic) {
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    _schoolShakeController = ShakeController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _userShakeController = ShakeController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    super.initState();
    setNewUserPrefs();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void resetInputFieldColor() {
    setState(() {
      _isWrongUser = false;
      _isWrongSchool = false;
    });
  }

  void setNewUserPrefs() async {
    isFirstUser = (await getAllUsers(decrypt: false)).length > 0;
    globals.prefs.setBool("isNew", true);
    globals.prefs.setBool("isNotNew", true);
  }

  Future<void> login() async {
    tempUser.school = selectedSchool.code;
    tempUser.username = _userController.text;
    tempUser.password = _passController.text;
    TokenResponse result = await RequestHandler.login(tempUser)
        .timeout(Duration(seconds: 15), onTimeout: () {
      return TokenResponse(status: "TIMEOUT");
    });
    if (result.status == "OK") {
      try {
        User temp = await encryptUserDetails(tempUser);
        temp.current = isFirstUser;
        await insertUser(temp);
        Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: "insertUser encryptUserDetails",
        );
        Fluttertoast.showToast(
          msg: getTranslatedString("errRestart"),
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 18.0,
        );
      }
    } else if (result.status == "invalid_username_or_password") {
      //Wrong username or password
      setState(() {
        _userShakeController.shake();
        _isWrongUser = true;
      });
      Fluttertoast.showToast(
        msg: getTranslatedString("wrongUserPass"),
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18.0,
      );
    } else if (result.status == "TIMEOUT") {
      Fluttertoast.showToast(
        msg: getTranslatedString("timeoutErr"),
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18.0,
      );
    } else {
      FirebaseAnalytics().logEvent(
        name: "unkownLoginResponse",
        parameters: {
          "result": result,
        },
      );
      Fluttertoast.showToast(
        msg: "${getTranslatedString('unkError')}\n $result",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18.0,
      );
    }
  }

  bool checkForEmptyFields() {
    if (schoolController.text == "" ||
        _userController.text == "" ||
        _passController.text == "") {
      setState(() {
        if (_userController.text == "" || _passController.text == "") {
          _userShakeController.shake();
          _isWrongUser = true;
        }
        if (schoolController.text == "") {
          _schoolShakeController.shake();
          _isWrongSchool = true;
        }
      });
      Fluttertoast.showToast(
        msg: getTranslatedString("mustntLeaveEmpty"),
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18.0,
      );
      return true;
    } else {
      return false;
    }
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

    final codeInput = ShakeView(
      controller: _schoolShakeController,
      child: TextFormField(
        focusNode: _codeFocus,
        controller: schoolController,
        readOnly: true,
        onTap: () {
          showSelectDialog();
        },
        onChanged: (text) {
          if (_isWrongSchool) {
            setState(() {
              _isWrongSchool = false;
            });
          }
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: getTranslatedString("schId"),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 99, 255, 218),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide:
                BorderSide(color: _isWrongSchool ? Colors.red : Colors.grey),
          ),
        ),
        onFieldSubmitted: (String input) {
          _codeFocus.unfocus();
          FocusScope.of(context).requestFocus(_userFocus);
        },
      ),
    );

    final usernameInput = ShakeView(
      controller: _userShakeController,
      child: TextFormField(
        focusNode: _userFocus,
        controller: _userController,
        onChanged: (text) {
          if (_isWrongUser) {
            setState(() {
              _isWrongUser = false;
            });
          }
        },
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: getTranslatedString("username"),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 99, 255, 218),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide:
                BorderSide(color: _isWrongUser ? Colors.red : Colors.grey),
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
      controller: _userShakeController,
      child: TextFormField(
        focusNode: _passFocus,
        controller: _passController,
        autofocus: false,
        onChanged: (text) {
          if (_isWrongUser) {
            setState(() {
              _isWrongUser = false;
            });
          }
        },
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 99, 255, 218),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide:
                BorderSide(color: _isWrongUser ? Colors.red : Colors.grey),
          ),
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (term) async {
          _passFocus.unfocus();
          FirebaseAnalytics().logEvent(name: "sign_up");
          resetInputFieldColor();
          if (!isPressed) {
            isPressed = true;
            //If there is an empty field show warning and return
            if (!checkForEmptyFields()) {
              resetButtonAnimation();
              await login();
              resetButtonAnimation();
            }
            isPressed = false;
          }
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
        resetInputFieldColor();
        if (!isPressed) {
          isPressed = true;
          //If there is an empty field show warning and return
          if (!checkForEmptyFields()) {
            reset();
            await login();
            reset();
          }
          isPressed = false;
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
