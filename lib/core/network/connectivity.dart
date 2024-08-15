import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class Connectivity {
  static Future<bool> hasInternetAccess()  async {
    return await InternetConnectionCheckerPlus().hasConnection;
    
  }
}