import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:novynaplo/helpers/toasts/okToast.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

import 'builders/bankAccDetailsBuilder.dart';
import 'builders/guardianDetailsBuilder.dart';
import 'builders/personalDetailsBuilder.dart';
import 'builders/schoolDetailsBuilder.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({
    @required this.userDetails,
    @required this.setStateCallback,
  });
  final Student userDetails;
  final Function setStateCallback;

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final TextEditingController _newNickNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Color pickerColor = Color(0xff443a49);
  TextEditingController hexInput = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            globals.appBarColoredByUser ? widget.userDetails.color : null,
        foregroundColor:
            globals.appBarTextColoredByUser ? widget.userDetails.color : null,
        title: Text(widget.userDetails.name),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                showColorPickerDialog(widget.userDetails);
              },
              child: Container(
                width: (MediaQuery.of(context).size.width / 5)
                        .clamp(10, 100)
                        .toDouble() +
                    18,
                height: (MediaQuery.of(context).size.width / 5)
                        .clamp(10, 100)
                        .toDouble() +
                    18,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.userDetails.color,
                ),
                child: Icon(
                  Feather.user,
                  size: (MediaQuery.of(context).size.width / 5)
                      .clamp(10, 100)
                      .toDouble(),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () => showNicknameChange(),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.userDetails.nickname ??
                            widget.userDetails.name,
                        style: TextStyle(fontSize: 21),
                      ),
                      WidgetSpan(
                        child: SizedBox(width: 10),
                      ),
                      WidgetSpan(
                        child: Icon(Icons.edit),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Divider(),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              //* Personal details
              PersonalDetailsDropdown(
                userDetails: widget.userDetails,
              ),
              SizedBox(height: 10),
              Divider(),
              //* Guardian details
              GuardianDetailsDropdown(
                userDetails: widget.userDetails,
              ),
              SizedBox(height: 10),
              Divider(),
              //* Bank details
              BankAccountDropdown(
                bankAccDetails: widget.userDetails.bankAccount,
              ),
              SizedBox(height: 10),
              Divider(),
              //* School details
              SchoolDetailsDropdown(
                schoolDetails: widget.userDetails.institution,
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> showNicknameChange() async {
    _newNickNameController.text = widget.userDetails.nickname ?? "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(getTranslatedString("changeNickname")),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _newNickNameController,
              validator: (newNickName) {
                if (newNickName == "manageUsers") {
                  ErrorToast.showErrorToastLong(
                    context,
                    getTranslatedString("unkError"),
                  );
                  return getTranslatedString("unkError");
                }
                if (globals.allUsers.any((element) =>
                    element.nickname == newNickName &&
                    element.uid != widget.userDetails.uid)) {
                  ErrorToast.showErrorToastLong(
                    context,
                    getTranslatedString("noSameUserNick"),
                  );
                  return getTranslatedString("noSameUserNick");
                }
                return null;
              },
              onFieldSubmitted: (inp) async {
                if (_formKey.currentState.validate()) {
                  if (await handleNicknameSave())
                    setState(() {
                      Navigator.pop(context);
                    });
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  if (await handleNicknameSave())
                    setState(() {
                      Navigator.pop(context);
                    });
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> handleNicknameSave() async {
    String newNickName = _newNickNameController.text;
    if (widget.userDetails.nickname == newNickName) return true;
    try {
      await DatabaseHelper.changeNickname(
        widget.userDetails,
        newNickName,
      );
      setState(() {
        OkToast.showOkToast(getTranslatedString("nickSucces"));
      });
      widget.setStateCallback();
      return true;
    } catch (e, s) {
      ErrorToast.showErrorToastLong(
        context,
        getTranslatedString("unkError"),
      );
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        printDetails: true,
        reason: "handleNicknameSave",
      );
      return false;
    }
  }

  void showColorPickerDialog(Student input) {
    pickerColor = input.color;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            input.nickname ?? input.name,
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              enableAlpha: false,
              pickerAreaHeightPercent: 0.8,
              hexInputBar: true,
              hexInputController: hexInput,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                await DatabaseHelper.changeUserColor(
                  input,
                  pickerColor,
                );
                setState(() {
                  input.color = pickerColor;
                  int userIndex = globals.allUsers.indexWhere((element) => element.userId == input.userId);
                  globals.allUsers[userIndex].color = pickerColor;
                  if (globals.currentUser.userId == input.userId) {
                    globals.currentUser.color = pickerColor;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
}
