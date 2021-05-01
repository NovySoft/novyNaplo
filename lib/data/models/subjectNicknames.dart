class SubjectNicknames {
  String fullName;
  String nickName;
  String category;
  SubjectNicknames({
    this.fullName,
    this.nickName,
    this.category,
  });

  @override
  String toString() => "$fullName:$nickName:$category";
}
