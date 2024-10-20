import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/school.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/notification/notificationHelper.dart';
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:novynaplo/helpers/toasts/okToast.dart';
import 'package:novynaplo/helpers/ui/animations/circularProgressButton.dart'
    as progressButton;
import 'package:novynaplo/helpers/ui/animations/shake_view.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/SchoolSearchList.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksTab;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as fpath;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';

Function resetButtonAnimation;
var schoolList = [];
School selectedSchool = School();
final TextEditingController schoolController = TextEditingController();

class KeyLoaderKey {
  static final keyLoader = new GlobalKey<State>();
}

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  LoginPage({
    this.userDetails,
    this.isAutoFill = false,
    this.isEditing = false,
    this.isNewUser = false,
    this.setStateCallback,
  });

  final Student userDetails;
  final bool isAutoFill;
  final bool isEditing;
  final bool isNewUser;
  final Function setStateCallback;

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
  Student tempUser = Student();
  bool isFirstUser = false;
  StreamSubscription<ConnectivityResult> networkChangeListener;
  bool inputEnabled = true;
  String textBoxContent = "";

  void showSelectDialog() {
    setState(() {
      showDialog<School>(
          context: context,
          builder: (BuildContext context) {
            return new SchoolSearchList();
          }).then((dynamic) {
        setState(() {
          _isWrongSchool = false;
        });
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
    DatabaseHelper.getAllUsers()
        .then((value) => isFirstUser = (value.length <= 0));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isEditing) {
        if (widget.userDetails.school == null ||
            widget.userDetails.username == null ||
            widget.userDetails.password == null) {
          ErrorToast.showErrorToast(
            getTranslatedString("errWhileMigratingManLogin"),
          );
        } else {
          String userName = widget.userDetails.nickname != null
              ? widget.userDetails.nickname
              : widget.userDetails.name;
          setState(() {
            //Set school
            schoolController.text = widget.userDetails.school;
            selectedSchool.code = widget.userDetails.school;
            //Set username
            _userController.text = widget.userDetails.username;
            //Set text for editing
            textBoxContent = getTranslatedString(
              "currEditing",
              replaceVariables: [userName],
            );
          });
          ErrorToast.showErrorToast(
            getTranslatedString("reEnterPass"),
          );
        }
      }
      if (widget.isAutoFill) {
        String path =
            fpath.join(await getDatabasesPath(), 'NovyNalploDatabase.db');
        File file = new File(path);
        if (file.existsSync()) {
          file.deleteSync();
          //Delete old database
        }
        if (widget.userDetails.school == null ||
            widget.userDetails.username == null ||
            widget.userDetails.password == null) {
          ErrorToast.showErrorToast(
            getTranslatedString("errWhileMigratingManLogin"),
          );
        } else {
          setState(() {
            //Set school
            schoolController.text = widget.userDetails.school;
            selectedSchool.code = widget.userDetails.school;
            //Set username
            _userController.text = widget.userDetails.username;
            //Set password
            _passController.text = widget.userDetails.password;
          });
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return SpinnerDialog();
            },
          );
          isPressed = true;
          resetButtonAnimation();
          await login();
          resetButtonAnimation();
        }
      }
      networkChangeListener = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) {
          if (result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi) {
            OkToast.showOkToast(
              getTranslatedString("netRestored"),
            );
            setState(() {
              inputEnabled = true;
            });
          } else {
            setState(() {
              inputEnabled = false;
            });
          }
        },
      );
      if (!(await NetworkHelper.isNetworkAvailable())) {
        showNoNetAlert(context: context);
        setState(() {
          inputEnabled = false;
        });
      } else {
        setState(() {
          inputEnabled = true;
        });
      }
    });
  }

  Future<void> showNoNetAlert({BuildContext context}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: globals.darker ? 0 : 24,
          title: Text(getTranslatedString("status")),
          content: Text(getTranslatedString("noNetConnectRetry")),
          actions: <Widget>[
            TextButton(
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

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (networkChangeListener != null) {
      networkChangeListener.cancel();
    }
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

  Future<void> login() async {
    tempUser.school = selectedSchool.code;
    tempUser.username = _userController.text;
    tempUser.password = _passController.text;
    if (globals.allUsers != null) {
      if (globals.allUsers.indexWhere(
            (element) =>
                element.username == tempUser.username &&
                element.password == tempUser.password,
          ) !=
          -1) {
        //User alread exists
        ErrorToast.showErrorToast(
          getTranslatedString("userAlreadyExits"),
        );
        return;
      }
    }
    //!FIGYELEM, itt a régi deprecated login metódus kellene!
    TokenResponse result = await RequestHandler.loginWRefresh(tempUser)
        .timeout(Duration(seconds: 15), onTimeout: () {
      return TokenResponse(status: "TIMEOUT");
    });
    if (result.status == "OK") {
      try {
        Student finalUserObject = tempUser;
        finalUserObject.current = isFirstUser;
        finalUserObject = await RequestHandler.getStudentInfo(
          tempUser,
          embedDetails: true,
        );
        if (widget.isEditing) {
          finalUserObject.userId = widget.userDetails.userId;
          await DatabaseHelper.updatePassword(finalUserObject);
        } else {
          List<int> allColors = myListOfRandomColors
              .map(
                (e) => e.value,
              )
              .toList();
          for (Student user in (globals.allUsers ?? [])) {
            allColors.remove(user.color.value);
          }
          if (allColors.length == 0) {
            allColors = myListOfRandomColors
                .map(
                  (e) => e.value,
                )
                .toList();
          }
          finalUserObject.color =
              Color(allColors[Random().nextInt(allColors.length)]);

          if ((globals.allUsers ?? []).length == 0) {
            finalUserObject.color = Colors.orange;
          }

          if ((globals.allUsers ?? []).length == 1 &&
              (globals.appBarColoredByUser == false &&
                  globals.appBarTextColoredByUser == false)) {
            //Just double checking to avoid a "invisible app bar"
            if (globals.prefs.getBool('appBarColoredByUser') == false &&
                globals.prefs.getBool('appBarTextColoredByUser') == false) {
              if (globals.prefs.getBool('darker')) {
                await globals.prefs.setBool('appBarTextColoredByUser', true);
                globals.appBarTextColoredByUser = true;
              } else {
                await globals.prefs.setBool('appBarColoredByUser', true);
                globals.appBarColoredByUser = true;
              }
            }
          }

          await DatabaseHelper.insertUser(finalUserObject);
          await globals.prefs.setBool("isNew", false);

          Student nonEncrypted = finalUserObject;
          nonEncrypted.username = tempUser.username;
          nonEncrypted.password = tempUser.password;
          nonEncrypted.school = tempUser.school;
          if (!widget.isNewUser) {
            globals.currentUser = nonEncrypted;
          }
          if (widget.isAutoFill) {
            //*Delete the prefs version of login data
            globals.prefs.remove("code");
            globals.prefs.remove("user");
            globals.prefs.remove("password");
            //Pop the loading spinner
            Navigator.of(
              KeyLoaderKey.keyLoader.currentContext,
              rootNavigator: true,
            ).pop();
          }
        }
        if (widget.setStateCallback != null) {
          globals.allUsers = await DatabaseHelper.getAllUsers();
          widget.setStateCallback();
        }
        if (widget.isNewUser) {
          Navigator.of(context).pop();
        } else {
          //Request notification perms (for the first time)
          globals.prefs.setBool("isOnboradingDone", true);
          globals.isOnboradingDone = true;
          NotificationHelper.flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              .requestPermission();

          Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: "insertUser encryptUserDetails",
        );
        ErrorToast.showErrorToast(
          getTranslatedString("errRestart"),
        );
      }
    } else if (result.status == "invalid_username_or_password") {
      //Wrong username or password
      setState(() {
        _userShakeController.shake();
        _isWrongUser = true;
      });
      ErrorToast.showErrorToast(
        getTranslatedString("wrongUserPass"),
      );
    } else if (result.status == "TIMEOUT") {
      ErrorToast.showErrorToast(
        getTranslatedString("timeoutErr"),
      );
    } else {
      //'Handled error'
      ErrorToast.showErrorToastLong(
        context,
        result.status,
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
      ErrorToast.showErrorToast(
        getTranslatedString("mustntLeaveEmpty"),
      );
      return true;
    } else {
      return false;
    }
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

    final codeInput = ShakeView(
      controller: _schoolShakeController,
      child: TextFormField(
        enabled: inputEnabled && !widget.isEditing,
        style: TextStyle(
          color: inputEnabled && !widget.isEditing
              ? Theme.of(context).textTheme.titleMedium.color
              : Colors.grey,
        ),
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
          hintStyle: inputEnabled && !widget.isEditing
              ? null
              : TextStyle(color: Colors.grey),
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: Colors.grey),
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
        enabled: inputEnabled && !widget.isEditing,
        style: TextStyle(
          color: inputEnabled && !widget.isEditing
              ? Theme.of(context).textTheme.titleMedium.color
              : Colors.grey,
        ),
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
          hintStyle: inputEnabled ? null : TextStyle(color: Colors.grey),
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: Colors.grey),
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
        enabled: inputEnabled,
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
            //TODO: An animation would be nice to have
            child: Icon(_obscureText ? MdiIcons.eyeOff : MdiIcons.eye),
          ),
          hintText: getTranslatedString("password"),
          hintStyle: inputEnabled ? null : TextStyle(color: Colors.grey),
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (term) async {
          _passFocus.unfocus();
          FirebaseAnalytics.instance.logEvent(name: "sign_up");
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
        if (!inputEnabled) {
          showNoNetAlert(context: context);
        }
        if (!isPressed && inputEnabled) {
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
            SizedBox(height: 24),
            Center(
              child: Text(
                textBoxContent,
              ),
            ),
            SizedBox(height: 24),
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

class SpinnerDialog extends StatefulWidget {
  @override
  SpinnerDialogState createState() => new SpinnerDialogState();
}

class SpinnerDialogState extends State<SpinnerDialog> {
  String loadingText = getTranslatedString("plsWait");
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: SimpleDialog(
        key: KeyLoaderKey.keyLoader,
        backgroundColor: Colors.black54,
        children: <Widget>[
          Center(
            child: Column(
              children: [
                SpinKitPouringHourGlass(color: Colors.lightBlueAccent),
                SizedBox(height: 10),
                Text(
                  getTranslatedString("migrateDB"),
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
