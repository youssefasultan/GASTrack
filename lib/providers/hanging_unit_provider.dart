import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gas_track/models/hose.dart';

import '../helpers/data/request_builder.dart';
import '../helpers/data/shared.dart';
import '../models/hanging_unit.dart';
import '../models/tank.dart';

class HangingUnitsProvider with ChangeNotifier {
  List<HangingUnit> _hangingUnitItems = [];
  List<Tank> _tanks = [];
  List<Hose> _hoseList = [];

  double _total = 0.0;

  double get getTotalSales {
    return _total;
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
      final userData = await Shared.getUserdata();

      final response = await RequestBuilder().buildGetRequest(
          "GasoItemsSet?\$filter=FunctionalLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}'&");

      final responseData = json.decode(response.body);
      final extractedData = responseData['d']['results'] as List<dynamic>;

      if (extractedData.isEmpty) {
        throw ArgumentError("No Equipments Found.");
      }

      addHangingUnits(extractedData, userData);

      addHoses(extractedData);

      matchHoseToHangingUnit();

      if (userData['shiftType'] == 'F') {
        addTanks(extractedData);
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  void matchHoseToHangingUnit() {
    for (var hangingUnit in _hangingUnitItems) {
      for (var hose in _hoseList) {
        if (hangingUnit.equipment == hose.equipmentId) {
          hangingUnit.hoseList.add(hose);
        }
      }
    }
  }

  void addTanks(List<dynamic> extractedData) {
    final loadedTanks = getUniqueObjects(extractedData, 'Material')
        .map((product) => Tank(material: product['Material']))
        .toList();

    _tanks = loadedTanks;
  }

  void addHoses(List<dynamic> extractedData) {
    final loadedHose = extractedData
        .map((e) => Hose(
              material: e['Material'],
              materialDesc: e['MaterialDesc'],
              lastReading: double.parse(e['LastRead']),
              lastAmount: double.parse(e['LastAmount']),
              unitPrice: double.parse(e['PricingUnit']),
              measuringUnit: e['Measurmntrangeunit'],
              measuringPoint: int.parse(e['MeasuringPoint']),
              measuringPointDesc: e['MeasuringPointDesc'],
              equipmentId: e['Equipment'],
              index: extractedData.indexOf(e),
              inActiveFlag: e['InactiveFlag'] as bool,
            ))
        .toList();
    _hoseList = loadedHose;
  }

  void addHangingUnits(
      List<dynamic> extractedData, Map<String, String> userData) {
    final loadedHangingUnits = getUniqueObjects(extractedData, 'Equipment')
        .map((element) => HangingUnit(
              [],
              equipmentDesc: element['EquipmentDescription'],
              objectNumber: element['ObjectNumber'],
              equipment: element['Equipment'],
              shiftLoc: userData['funLoc']!,
              shiftDate: userData['shiftDate']!,
              shiftNo: userData['shiftNo']!,
              shiftType: userData['shiftType']!,
            ))
        .toList();

    _hangingUnitItems = loadedHangingUnits;
  }

  List<dynamic> getUniqueObjects(List<dynamic> jsonList, String key) {
    return jsonList.fold<List<dynamic>>(
      [],
      (acc, obj) {
        if (!acc.any((item) => item[key] == obj[key])) {
          acc.add(obj);
        }
        return acc;
      },
    );
  }

  void calculateTankQuantity() {
    // calaculate tank quantity
    if (_tanks.isNotEmpty) {
      for (var tank in _tanks) {
        final productsList = _hoseList
            .where((element) => element.material == tank.material)
            .toList();
        final totalQuantity =
            productsList.fold(0.0, (sum, product) => sum + product.quantity);
        tank.quantity = totalQuantity;
      }
    }
    notifyListeners();
  }

  void calculateTotal() {
    // calculate total sales
    _total = 0.0;
    for (var element in _hoseList) {
      _total += (element.quantity * element.unitPrice);
    }

    notifyListeners();
  }

  List<Hose?> validateProducts() {
    final itemsWithIncorrectAmount = _hoseList
        .where((item) => item.enteredReading != 0.0)
        .where((item) =>
            (item.enteredReading - item.lastReading) * item.unitPrice !=
            (item.enteredAmount - item.lastAmount))
        .toList();

    return itemsWithIncorrectAmount.isEmpty ? [] : itemsWithIncorrectAmount;
  }
}
