class OsztalyCsoport {
  String uid;

  OsztalyCsoport({this.uid});

  OsztalyCsoport.fromJson(Map<String, dynamic> json) {
    uid = json['Uid'];
  }
}
