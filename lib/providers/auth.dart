import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gasolina/helpers/data/request_builder.dart';
import 'package:gasolina/helpers/data/shared.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? deviceId;
  // user data
  String? _location;
  String? _locationDescription;
  String? _username;
  String? _shiftDate;
  String? _shiftNo;
  String? _shiftTime;

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

  String? get getUsername {
    if (_username != null) {
      return _username!;
    }
    return null;
  }

  String? get getShiftNo {
    if (_shiftNo != null) {
      return _shiftNo!;
    }
    return null;
  }

  bool get isAuth {
    return getLocation != null && getLocation!.isNotEmpty;
  }

  Future<void> login(String username, String password) async {
    return _authenticate(username, password);
  }

  Future<void> _authenticate(String username, String password) async {
    try {
      final response = await RequestBuilder().buildGetRequest(
          "GasolinaLoginSet(Username='${username.toUpperCase().trim()}',Password='$password',Locked=false)?");

      final responseData = json.decode(response.body);

      if (responseData['d']['Found'] != '0') {
        String error = await getErrorMsg(responseData['d']['Found'].toString());

        throw HttpException(error);
      }

      _location = responseData['d']['ShiftLocation'];
      _locationDescription = responseData['d']['ShiftLocationDesc'];
      _username = responseData['d']['Username'];
      _shiftDate = responseData['d']['ShiftDate'];
      _shiftNo = responseData['d']['Shift'];
      _shiftTime = responseData['d']['ShiftTime'];

      await Shared.saveUserData(_location!, _locationDescription!, _username!,
          _shiftDate!, _shiftNo!, _shiftTime!);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<String> getErrorMsg(String code) async {
    final String defaultLocale = Platform.localeName;
    final String lang =
        defaultLocale.split('_')[0].toUpperCase(); // get locale language

    final response = await RequestBuilder()
        .buildGetRequest("ZGASO_MSG(MsgCode='0$code',Lang='$lang')?");

    final responseData = json.decode(response.body);

    return responseData['d']['Msg'];
  }

  Future<void> register(String username, String password, String url) async {
    try {
      await Shared.saveSettings(username, password, url);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _location = null;
      notifyListeners();

      await Shared.clearUserData();
    } catch (error) {
      rethrow;
    }
  }
}
