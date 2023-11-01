import 'package:shared_preferences/shared_preferences.dart';

class Shared {
// pref constatnts
  static const String _serviceIp = 'serviceIp';
  static const String _serviceUser = 'serviceUser';
  static const String _servicePass = 'servicePass';
  static const String _functionalLocation = 'functionalLocation';
  static const String _locationDesc = 'locationDesc';
  static const String _loggedInUser = 'username';
  static const String _shiftDate = 'shiftDate';
  static const String _shiftNo = 'shiftNo';
  static const String _shiftTime = 'shiftTime';
  static const String _shiftType = 'shiftType';
  static const String _name = 'name';

  static Future<void> saveSettings(
      String username, String password, String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_serviceIp, url);
    prefs.setString(_serviceUser, username);
    prefs.setString(_servicePass, password);
  }

  static Future<void> saveUserData(
      String location,
      String locationDesc,
      String loggedInUser,
      String shiftDate,
      String shiftNo,
      String shiftTime,
      String shiftType,
      String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(_functionalLocation, location);
    prefs.setString(_locationDesc, locationDesc);
    prefs.setString(_loggedInUser, loggedInUser);
    prefs.setString(_shiftDate, shiftDate);
    prefs.setString(_shiftNo, shiftNo);
    prefs.setString(_shiftTime, shiftTime);
    prefs.setString(_shiftType, shiftType);
    prefs.setString(_name, name);
  }

  static Future<Map<String, String>> getSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'ip': '${prefs.getString(_serviceIp)}',
      'username': '${prefs.getString(_serviceUser)}',
      'password': '${prefs.getString(_servicePass)}',
    };
  }

  static Future<Map<String, String>> getUserdata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'funLoc': '${prefs.getString(_functionalLocation)}',
      'funLocDesc': '${prefs.getString(_locationDesc)}',
      'user': '${prefs.getString(_loggedInUser)}',
      'shiftDate': '${prefs.getString(_shiftDate)}',
      'shiftNo': '${prefs.getString(_shiftNo)}',
      'shiftTime': '${prefs.getString(_shiftTime)}',
      'shiftType': '${prefs.getString(_shiftType)}',
      'name': '${prefs.getString(_name)}',
    };
  }

  static Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_functionalLocation, '');
    prefs.setString(_locationDesc, '');
    prefs.setString(_loggedInUser, '');
    prefs.setString(_shiftDate, '');
    prefs.setString(_shiftNo, '');
  }
}
