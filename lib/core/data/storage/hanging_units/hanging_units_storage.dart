import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gas_track/features/home/model/hanging_unit.dart';
import 'package:gas_track/features/home/model/tank.dart';

class HangingUnitsStorage {
  HangingUnitsStorage();

  final storage = const FlutterSecureStorage();
  String hangingUnitKey = 'hangingUnits';
  String tankKey = 'tanks';

  Future<List<HangingUnit>> getHangingUnits() async {
    try {
      final resultList = await storage.read(key: hangingUnitKey);
      final resultData = jsonDecode(resultList!) as List<dynamic>;

      return List<HangingUnit>.from(
        resultData.map((e) => HangingUnit.fromSavedJson(e)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Tank>> getTanks() async {
    try {
      final resultList = await storage.read(key: tankKey);
      final resultData = jsonDecode(resultList!) as List<dynamic>;

      return List<Tank>.from(
        resultData.map((e) => Tank.fromJson(e)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveHangingUinits(List<HangingUnit> hangingUnitsList) async {
    try {
      await storage.write(
          key: hangingUnitKey, value: jsonEncode(hangingUnitsList));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveTanks(List<Tank> tankList) async {
    try {
      await storage.write(key: tankKey, value: jsonEncode(tankList));
    } catch (e) {
      rethrow;
    }
  }
}
