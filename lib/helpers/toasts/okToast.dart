import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OkToast {
  static void showOkToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }
}
