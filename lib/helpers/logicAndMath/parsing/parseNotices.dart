import 'package:novynaplo/data/database/insertSql.dart';
import 'package:novynaplo/data/models/notice.dart';

Future<List<Notice>> parseNotices(var input) async {
  if (input != null && input["Notes"] != null) {
    List<Notice> noticesArray = [];
    var notices = input["Notes"];
    for (var n in notices) {
      noticesArray.add(Notice.fromJson(n));
    }
    await batchInsertNotices(noticesArray);
    return noticesArray;
  } else {
    return [];
  }
}
