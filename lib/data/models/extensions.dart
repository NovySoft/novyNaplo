extension MyDateTime on DateTime {
  bool isSameDay(DateTime other) {
    return this.day == other.day &&
        this.month == other.month &&
        this.year == other.year;
  }
}
