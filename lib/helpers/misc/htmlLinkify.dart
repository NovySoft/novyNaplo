String htmlLinkify(String input) {
  if (input.contains("href")) {
    //Sometimes kreta is nice enough to put the link tag automatically, so we dont have to
    //And we return if it contains once, because if it contains once then all links SHOULD be put inside link tags
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
