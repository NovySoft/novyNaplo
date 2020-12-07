class User {
  String username;
  String password;
  String school;
  String token;
  String iv;
  DateTime tokenDate;
  int id;

  Map<String, dynamic> toMap() {
    return {
      'databaseId': id,
      'username': username,
      'password': password,
      'iv': iv,
      'code': school,
    };
  }

  User({
    this.username,
    this.password,
    this.school,
    this.token,
    this.id,
    this.iv,
  });
}
