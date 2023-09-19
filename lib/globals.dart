import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Logger logger = Logger();
late SharedPreferences prefs;

Future<void> setGlobals() async {
  prefs = await SharedPreferences.getInstance();
}
