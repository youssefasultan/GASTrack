import 'dart:convert';

import 'package:gas_track/core/data/request_builder.dart';
import 'package:gas_track/core/data/shared_pref/shared.dart';
import 'package:gas_track/core/helper/data_manipulation.dart';
import 'package:gas_track/features/home/model/tank.dart';

class HangingUnitRepo {
  HangingUnitRepo();

  Future<List<dynamic>> fetchProducts() async {
    try {
      final userData = await Shared.getUserdata();

      final response = await RequestBuilder.buildGetRequest(
          "GasoItemsSet?\$filter=FunctionalLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}'&");

      final responseData = json.decode(response.body);
      final extractedData = responseData['d']['results'] as List<dynamic>;

      if (extractedData.isEmpty) {
        throw ArgumentError("No Equipments Found.");
      }

      return extractedData;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Tank>> addTanks(
      String funLoc, List<dynamic> hangingUnitResponse) async {
    try {
      final response = await RequestBuilder.buildGetRequest(
          "GasTankSet?\$filter=ShiftLocation eq '$funLoc'&");

      final responseData = json.decode(response.body);
      var extractedData = responseData['d']['results'] as List<dynamic>;


      // if the extracted data is empty that means that no Tank table is created 
      // in the backend, so we need to create it first using unique materials from the
      // hanging units fetch 
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
