import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/student.dart';

class TokenResponse {
  String status;
  Student userinfo;
  TokenResponse({
    @required this.status,
    this.userinfo,
  });
}
