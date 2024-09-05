import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class Shared {
  Shared._internal();
  static final Shared _singleton = Shared._internal();

  factory Shared() {
    return _singleton;
  }
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

  static const String _formatedDate = 'dateFormatted';
  static const String _sysDate = 'sysDate';

  static const String _vpnUser = 'vpnUser';
  static const String _vpnPass = 'vpnPass';

  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> saveSettings(
      String username, String password, String url) async {
    await Future.wait([
      storage.write(key: _serviceIp, value: url),
      storage.write(key: _serviceUser, value: username),
      storage.write(key: _servicePass, value: password),
    ]);
  }

  Future<void> saveUserData(
      String location,
      String locationDesc,
      String loggedInUser,
      String shiftDate,
      String shiftNo,
      String shiftTime,
      String shiftType,
      String name,
      String formattedDate) async {
    await Future.wait([
      storage.write(key: _functionalLocation, value: location),
      storage.write(key: _locationDesc, value: locationDesc),
      storage.write(key: _loggedInUser, value: loggedInUser),
      storage.write(key: _shiftDate, value: shiftDate),
      storage.write(key: _shiftNo, value: shiftNo),
      storage.write(key: _shiftTime, value: shiftTime),
      storage.write(key: _shiftType, value: shiftType),
      storage.write(key: _name, value: name),
      storage.write(key: _formatedDate, value: formattedDate),
    ]);
  }

  Future<Map<String, String>> getSettings() async {
    final data = await storage.readAll();

    return {
      'ip': '${data[_serviceIp]}',
      'username': '${data[_serviceUser]}',
      'password': '${data[_servicePass]}',
    };
  }

  Future<bool> userDataFound() async {
    final funLoc = await storage.read(key: _functionalLocation);
    return funLoc!.isNotEmpty;
  }

  Future<Map<String, String>> getUserdata() async {
    final data = await storage.readAll();

    return {
      'funLoc': '${data[_functionalLocation]}',
      'funLocDesc': '${data[_locationDesc]}',
      'user': '${data[_loggedInUser]}',
      'shiftDate': '${data[_shiftDate]}',
      'shiftNo': '${data[_shiftNo]}',
      'shiftTime': '${data[_shiftTime]}',
      'shiftType': '${data[_shiftType]}',
      'name': '${data[_name]}',
      'formattedDate': '${data[_formatedDate]}',
    };
  }

  Future<void> clearUserData() async {
    await Future.wait([
      storage.delete(key: _functionalLocation),
      storage.delete(key: _locationDesc),
      storage.delete(key: _loggedInUser),
      storage.delete(key: _shiftDate),
      storage.delete(key: _shiftNo),
      storage.delete(key: _formatedDate),
    ]);
  }

  Future<void> saveSystemDate(String date) async {
    await storage.write(key: _sysDate, value: date);
  }

  Future<DateTime> getSystemDate() async {
    try {
      final date = await storage.read(key: _sysDate);
      String formattedDate =
          "${date!.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}";

      return DateFormat('yyyy-MM-dd').parse(formattedDate);
    } catch (e) {
      rethrow;
    }
  }

  Future<DateTime> getShiftDate() async {
    final date = await storage.read(key: _formatedDate);

    return DateFormat('yyyy-MM-dd').parse(date!);
  }

  Future<void> saveVpnCredentials(String username, String password) async {
    await Future.wait([
      storage.write(key: _vpnUser, value: username),
      storage.write(key: _vpnPass, value: password),
    ]);
  }


  /// returns a map with key 'user' for username and 'pass' for password 
  Future<Map<String, String?>> getVpnCredentials() async {
    final data = await storage.readAll();

    return {
      'user': data[_vpnUser],
      'pass' : data[_vpnPass],
    };
  }
}
