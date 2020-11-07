String shortenSubject(String input) {
  if (input.toLowerCase().contains("kötelező komplex természettudomány")) {
    return "KKterm";
  }
  if (input.toLowerCase().contains("komplex természettudomány") &&
      !input.toLowerCase().contains("kötlező")) {
    return "Komplex természet";
  }
  return input;
}
