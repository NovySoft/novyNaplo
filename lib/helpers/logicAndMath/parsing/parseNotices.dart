import 'package:novynaplo/data/database/insertSql.dart';
import 'package:novynaplo/data/models/notices.dart';

Future<List<Notices>> parseNotices(var input) async {
  if (input != null && input["Notes"] != null) {
    List<Notices> noticesArray = [];
    var notices = input["Notes"];
    for (var n in notices) {
      noticesArray.add(Notices.fromJson(n));
    }
    await batchInsertNotices(noticesArray);
    return noticesArray;
  } else {
    return [];
  }
}
