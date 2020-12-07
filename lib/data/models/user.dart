import 'package:flutter/material.dart';

class User {
  String username;
  String password;
  String school;
  String token;
  String iv;
  DateTime tokenDate;
  int id;
  bool current;

  Map<String, dynamic> toMap() {
    return {
      'databaseId': id,
      'username': username,
      'password': password,
      'iv': iv,
      'code': school,
      'current': current ? 1 : 0,
    };
  }

  User({
    this.username,
    this.password,
    this.school,
    this.token,
    this.id,
    this.iv,
    this.current,
  });
}

class TokenResponse {
  String status;
  User userinfo;
  TokenResponse({
    @required this.status,
    this.userinfo,
  });
}
