import 'package:connectivity/connectivity.dart';

class NetworkHelper {
  static Future<bool> isNetworkAvailable() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }
}
