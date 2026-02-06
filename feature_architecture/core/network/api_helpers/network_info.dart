import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  static Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
    bool _isConnected = true;
    set setIsConnected(bool val) => _isConnected = val;

    bool get getIsConnected => _isConnected;
}
