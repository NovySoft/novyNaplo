String removeHTMLtags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  String temp = htmlText.replaceAll("<br>", " ");
  return temp.replaceAll(exp, '').trim();
}
