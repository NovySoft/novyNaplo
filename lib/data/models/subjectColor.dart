class SubjectColor {
  String id;
  int color;
  String category;
  SubjectColor({
    this.id,
    this.color,
    this.category,
  });

  @override
  String toString() => "$id:$color:$category";
}
