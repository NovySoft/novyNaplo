String capitalize(String word) {
  if (word == null ||
      word == "" ||
      word.length == 0 ||
      (word is String) == false) {
    return "";
  }
  if (word.length < 2) return word;
  return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}
