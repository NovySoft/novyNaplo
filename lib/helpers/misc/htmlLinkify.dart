String htmlLinkify(String input) {
  if (input.contains("href")) {
    //Sometimes kreta is nice enough to put the link tag automatically, so we dont have to
    //FIXME rewrite regex to ignore links that have the prefix href="
    return input;
  } else {
    RegExp regex = RegExp(
      r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?',
      multiLine: true,
      caseSensitive: false,
    );
    return input.replaceAllMapped(regex, (Match m) {
      return '<a href="${m.group(0)}">${m.group(0)}</a>';
    });
  }
}
