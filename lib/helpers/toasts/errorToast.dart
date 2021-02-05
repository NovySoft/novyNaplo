import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ErrorToast {
  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }
}
