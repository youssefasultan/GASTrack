import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gas_track/core/network/connectivity.dart';

import '../../../core/data/request_builder.dart';
import '../../../core/data/shared_pref/shared.dart';
import '../../../core/models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String? deviceId;
  // user data
  String? _location;
  String? _locationDescription;
  String? _username;
  String? _shiftDate;
  String? _shiftNo;
  String? _shiftTime;
  String? _name;
  String? _formattedDate;
  late String _shiftType;
  bool _lock = false;
  int _lockCounter = 0;
  bool _isAdmin = false;

  final shared = Shared();

  String? get getLocation {
    if (_location != null) {
      return _location!;
    }
    return null;
  }

  String? get getLocationDesc {
    if (_locationDescription != null) {
      return _locationDescription!;
    }
    return null;
  }

  String? get getName {
    if (_username != null) {
      return _name!;
    }
    return null;
  }

  String get getShiftType {
    return _shiftType;
  }

  String? get getShiftNo {
    if (_shiftNo != null) {
      return _shiftNo!;
    }
    return null;
  }

  bool get isAdmin {
    return _isAdmin;
  }

  bool get isAuth {
    return getLocation != null && getLocation!.isNotEmpty;
  }

  Future<void> login(String username, String password, String shiftType) async {
    try {
      // check weather there is internet access
      if (await Connectivity.hasInternetAccess()) {
        // fetch from api
        await _authenticate(username, password, shiftType);
      } else {
        // fetch from shared prefrence
        if (await shared.userDataFound()) {
          final userData = await shared.getUserdata();

          _location = userData['funLoc'];
          _locationDescription = userData['funLocDesc'];
          _username = userData['user'];
          _shiftDate = userData['shiftDate'];
          _shiftNo = userData['shiftNo'];
          _shiftTime = userData['shiftTime'];
          _isAdmin = false;
          _name = userData['name'];

          _shiftType = shiftType;

          notifyListeners();
        } else {
          throw Exception('No Internet Connection');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _authenticate(
      String username, String password, String shiftType) async {
    try {
      if (_lockCounter >= 3) {
        _lock = true;
      }

      final response = await RequestBuilder.buildGetRequest(
          "GasolinaLoginSet(Username='${username.toUpperCase().trim()}',Password='$password',ShiftType='$shiftType',Locked=$_lock)?");

      final responseData = json.decode(response.body);

      // if responseData['d']['Found'] not equal 0 that means there is an error
      if (responseData['d']['Found'] != '0') {
        // lock counter
        if (responseData['d']['Found'] == '1') {
          _lockCounter++;
        } else if (responseData['d']['Found'] == '2') {
          _lockCounter = 0;
          _lock = false;
        }

        // fetch error message and throw exception

        String error = await getErrorMsg(responseData['d']['Found'].toString());

        throw HttpException(error);
      }

      _location = responseData['d']['ShiftLocation'];
      _locationDescription = responseData['d']['ShiftLocationDesc'];
      _username = responseData['d']['Username'];
      _shiftDate = responseData['d']['ShiftDate'];
      _shiftNo = responseData['d']['Shift'];
      _shiftTime = responseData['d']['ShiftTime'];
      _isAdmin = responseData['d']['Admin'] as bool;
      _name = responseData['d']['Name'];
      _formattedDate = responseData['d']['ShiftDateStr'];
      _shiftType = shiftType;

      // save data in shared pref
      await shared.saveUserData(
        _location!,
        _locationDescription!,
        _username!,
        _shiftDate!,
        _shiftNo!,
        _shiftTime!,
        shiftType,
        _name!,
        _formattedDate!,
      );

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<String> getErrorMsg(String code) async {
    final String defaultLocale = Platform.localeName;
    final String lang =
        defaultLocale.split('_')[0].toUpperCase(); // get locale language

    final response = await RequestBuilder.buildGetRequest(
        "ZGASO_MSG(MsgCode='0$code',Lang='$lang')?");

    final responseData = json.decode(response.body);

    return responseData['d']['Msg'];
  }

  Future<void> logout() async {
    try {
      _location = null;
      notifyListeners();

      await shared.clearUserData();
    } catch (error) {
      rethrow;
    }
  }
}
