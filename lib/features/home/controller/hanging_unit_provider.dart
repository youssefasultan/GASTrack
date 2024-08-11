import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gas_track/core/helper/data_manipulation.dart';
import 'package:gas_track/features/home/model/hose.dart';

import '../../../core/data/request_builder.dart';
import '../../../core/data/shared_pref/shared.dart';
import '../model/hanging_unit.dart';
import '../model/tank.dart';

class HangingUnitsProvider with ChangeNotifier {
  List<HangingUnit> _hangingUnitItems = [];
  List<Tank> _tanks = [];
  List<Hose> _hoseList = [];

  double _totalSales = 0.0;
  double _creditAmount = 0.0;

  double get getTotalSales {
    return _totalSales;
  }

  double get getCreditAmount {
    return _creditAmount;
  }

  List<HangingUnit> get getHangingUnits {
    return _hangingUnitItems;
  }

  List<Hose> get getHoseList {
    return _hoseList;
  }

  List<Tank> get getTanks {
    return _tanks;
  }

  Future<void> fetchProducts() async {
    try {
      await fetchHangingUnitsFromApi();

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchHangingUnitsFromApi() async {
    final userData = await Shared.getUserdata();

    final response = await RequestBuilder.buildGetRequest(
        "GasoItemsSet?\$filter=FunctionalLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}'&");

    final responseData = json.decode(response.body);
    final extractedData = responseData['d']['results'] as List<dynamic>;

    if (extractedData.isEmpty) {
      throw ArgumentError("No Equipments Found.");
    }

    addHangingUnits(extractedData, userData);

    addHoses(extractedData);

    matchHosesToHangingUnits();

    if (userData['shiftType'] == 'F') {
      addTanks(userData['funLoc']!, extractedData);
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

  void addTanks(String funLoc, List<dynamic> hangingUnitResponse) async {
    try {
      final response = await RequestBuilder.buildGetRequest(
          "GasTankSet?\$filter=ShiftLocation eq '$funLoc'&");

      final responseData = json.decode(response.body);
      var extractedData = responseData['d']['results'] as List<dynamic>;

      if (extractedData.isEmpty) {
        extractedData =
            DataManipulation.getUniqueObjects(hangingUnitResponse, 'Material');

        final loadedTanks = extractedData
            .map(
              (e) => Tank(
                material: e['Material'],
                shiftStart: 0.0,
                unitPrice: double.parse(e['PricingUnit']),
              ),
            )
            .toList();

        _tanks = loadedTanks;
      } else {
        final loadedTanks = extractedData
            .map(
              (e) => Tank(
                material: e['Material'],
                shiftStart: double.parse(e['Quantity']),
                unitPrice: double.parse(e['PricingUnit']),
              ),
            )
            .toList();

        _tanks = loadedTanks;
      }
    } catch (error) {
      rethrow;
    }
  }

  void addHoses(List<dynamic> extractedData) {
    final loadedHose = extractedData
        .map((e) => Hose.fromJson(e, extractedData.indexOf(e)))
        .toList();
    _hoseList = loadedHose;
  }

  void addHangingUnits(
      List<dynamic> extractedData, Map<String, String> userData) {
    final loadedHangingUnits =
        DataManipulation.getUniqueObjects(extractedData, 'Equipment')
            .map((element) => HangingUnit.fromJson(element, userData))
            .toList();

    _hangingUnitItems = loadedHangingUnits;
  }

  void calculateTankQuantity() {
    // calaculate tank quantity
    if (_tanks.isNotEmpty) {
      for (var tank in _tanks) {
        final productsList = _hoseList
            .where((element) => element.material == tank.material)
            .toList();
        final totalQuantity = productsList.fold(
            0.0,
            (sum, product) =>
                sum + (product.totalQuantity - product.calibration));
        tank.quantity = totalQuantity;
        tank.amount = tank.quantity * tank.unitPrice;
      }
    }
    notifyListeners();
  }

  void calculateTotal() {
    // calculate total sales
    _totalSales = 0.0;
    for (var element in _hoseList) {
      _totalSales +=
          ((element.totalQuantity - element.calibration) * element.unitPrice);
    }

    notifyListeners();
  }

  Future<void> calaulateTotalwithCredit() async {
    try {
      final userData = await Shared.getUserdata();

      final response = await RequestBuilder.buildGetRequest(
          "GetConditionsSet?\$filter=ShiftLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}' and ShiftNo eq '${userData['shiftNo']}' and ShiftDate eq '${userData['formattedDate']!.replaceAll('-', '')}' &");

      final responseData = json.decode(response.body);

      _creditAmount = double.parse(responseData['d']['results'][0]['Amount']);

      double creditQty =
          double.parse(responseData['d']['results'][0]['Quantity']);

      double totalQty = calculateTotalQty();

      // remove credit qty from totalQty
      totalQty -= creditQty;

      _totalSales = totalQty * _hoseList.first.unitPrice;
      _totalSales += _creditAmount;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  double calculateTotalQty() =>
      _hoseList.fold(0.0, (sum, element) => sum + element.totalQuantity);

  List<Hose?> validateProducts() {
    final itemsWithIncorrectAmount = _hoseList
        .where((item) => item.enteredReading != 0.0)
        .where((item) =>
            (item.enteredReading - item.lastReading) * item.unitPrice !=
            (item.enteredAmount - item.lastAmount))
        .toList();

    return itemsWithIncorrectAmount.isEmpty ? [] : itemsWithIncorrectAmount;
  }

  List<Tank?> validateTanks() {
    final tanksWithoutEntries = _tanks
        .where((tank) => tank.quantity > 0)
        .where((tank) => tank.shiftEnd == null)
        .toList();
    return tanksWithoutEntries.isEmpty ? [] : tanksWithoutEntries;
  }
}
