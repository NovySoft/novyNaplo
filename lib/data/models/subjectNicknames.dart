class SubjectNicknames {
  String uid;
  String fullName;
  String nickName;
  String category;
  String teacher;

  SubjectNicknames({
    this.uid,
    this.fullName,
    this.nickName,
    this.category,
    this.teacher,
  });

  @override
  String toString() => "$fullName:$nickName:$category";
}
