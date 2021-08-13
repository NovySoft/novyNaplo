class KretaCert {
  String radixModulus;
  int exponent;
  String subject;
  String date;

  KretaCert({
    this.radixModulus,
    this.exponent,
    this.subject,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "radixModulus": this.radixModulus,
      "exponent": this.exponent,
      "subject": this.subject,
      "date": this.date,
    };
  }

  KretaCert.fromSqlite(Map<String, dynamic> map) {
    radixModulus = map["radixModulus"];
    exponent = map["exponent"];
    subject = map["subject"];
    date = map["date"];
  }
}
