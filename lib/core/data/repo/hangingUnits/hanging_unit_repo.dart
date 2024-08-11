import 'dart:convert';

import 'package:gas_track/core/data/request_builder.dart';
import 'package:gas_track/core/data/shared_pref/shared.dart';
import 'package:gas_track/core/helper/data_manipulation.dart';
import 'package:gas_track/features/home/model/hanging_unit.dart';
import 'package:gas_track/features/home/model/hose.dart';
import 'package:gas_track/features/home/model/tank.dart';

class HangingUnitRepo {
  HangingUnitRepo();

  List<HangingUnit> _hangingUnitItems = [];
  List<Hose> _hoseList = [];

  Future<(List<HangingUnit>, List<Hose>)> fetchProducts() async {
    try {
      final userData = await Shared.getUserdata();

      final response = await RequestBuilder.buildGetRequest(
          "GasoItemsSet?\$filter=FunctionalLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}'&");

      final responseData = json.decode(response.body);
      final extractedData = responseData['d']['results'] as List<dynamic>;

      if (extractedData.isEmpty) {
        throw ArgumentError("No Equipments Found.");
      }

      await addHangingUnits(extractedData, userData);

      await addHoses(extractedData);

      matchHosesToHangingUnits();

      if (userData['shiftType'] == 'F') {
        await addTanks(userData['funLoc']!, extractedData);
      }

      return (_hangingUnitItems, _hoseList);
    } catch (e) {
      rethrow;
    }
  }

  void matchHosesToHangingUnits() {
    for (var unit in _hangingUnitItems) {
      for (var hose in _hoseList) {
        if (unit.equipment == hose.equipmentId) {
          unit.hoseList.add(hose);
        }
      }
    }
  }

  Future<void> addHangingUnits(
      List<dynamic> extractedData, Map<String, String> userData) async {
    final loadedHangingUnits =
        DataManipulation.getUniqueObjects(extractedData, 'Equipment')
            .map((element) => HangingUnit.fromJson(element, userData))
            .toList();

    _hangingUnitItems = loadedHangingUnits;
  }

  Future<void> addHoses(List<dynamic> extractedData) async {
    final loadedHose = extractedData
        .map((e) => Hose.fromJson(e, extractedData.indexOf(e)))
        .toList();
    _hoseList = loadedHose;
  }

  Future<List<Tank>> addTanks(
      String funLoc, List<dynamic> hangingUnitResponse) async {
    try {
      final response = await RequestBuilder.buildGetRequest(
          "GasTankSet?\$filter=ShiftLocation eq '$funLoc'&");

      final responseData = json.decode(response.body);
      var extractedData = responseData['d']['results'] as List<dynamic>;

      if (extractedData.isEmpty) {
        extractedData =
            DataManipulation.getUniqueObjects(hangingUnitResponse, 'Material');

        return extractedData.map((e) => Tank.fromJson(e)).toList();
      } else {
        return extractedData.map((e) => Tank.fromJson(e)).toList();
      }
    } catch (error) {
      rethrow;
    }
  }
}
