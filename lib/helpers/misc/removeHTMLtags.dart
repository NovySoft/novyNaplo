RegExp htmlMatcher = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

String removeHTMLtags(String htmlText, {String brReplacement = " "}) {
  RegExp doubleSpaces = RegExp(r"[ ]{2,}", multiLine: true, caseSensitive: true);
  String temp = htmlText.replaceAll("<br>", brReplacement);
  return temp.replaceAll(htmlMatcher, ' ').replaceAll(doubleSpaces, ' ').trim();
}
