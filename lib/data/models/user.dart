//TODO Only decrypt once and store it here.
class User {
  String username;
  String password;
  String school;
  String token;
  DateTime tokenDate;

  User({
    this.username,
    this.password,
    this.school,
    this.token,
  });
}
