import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/event.dart';

Future<List<Event>> parseEvents(var input) async {
  List<Event> eventArray = [];
  try {
    for (var n in input) {
      eventArray.add(Event.fromJson(n));
    }
  } catch (e, s) {
    FirebaseCrashlytics.instance.recordError(
      e,
      s,
      reason: 'parseEvents',
      printDetails: true,
    );
    return [];
  }
  return eventArray;
}
