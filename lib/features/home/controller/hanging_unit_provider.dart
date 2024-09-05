import 'package:flutter/material.dart';
import 'package:gas_track/core/data/repo/hangingUnits/hanging_unit_repo.dart';
import 'package:gas_track/core/helper/data_manipulation.dart';
import 'package:gas_track/core/models/http_exception.dart';
import 'package:gas_track/features/home/model/hose.dart';

import '../../../core/data/shared_pref/shared.dart';
import '../model/hanging_unit.dart';
import '../model/tank.dart';

class HangingUnitsProvider with ChangeNotifier {
  final hangingUnitRpo = HangingUnitRepo();
  List<HangingUnit> _hangingUnitItems = [];
  List<Tank> _tanks = [];
  List<Hose> _hoseList = [];

  double _totalSales = 0.0;
  double _creditAmount = 0.0;
  double _mobileAmount = 0.0;

  double get getTotalSales {
    return _totalSales;
  }

  double get getCreditAmount {
    return _creditAmount;
  }

  double get getMobileAmount {
    return _mobileAmount;
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

  /// fetch hanging units
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

    final extractedData = await hangingUnitRpo.fetchProducts();

    addHangingUnits(extractedData, userData);

    addHoses(extractedData);

    matchHosesToHangingUnits();

    if (userData['shiftType'] == 'F') {
      addTanks(userData['funLoc']!, extractedData);
    }
  }

  /// match each hose with it's related hanging unit
  void matchHosesToHangingUnits() {
    for (var unit in _hangingUnitItems) {
      for (var hose in _hoseList) {
        if (unit.equipment == hose.equipmentId) {
          unit.hoseList.add(hose);
        }
      }
    }
  }

  /// fetch fuel tanks if shift type is F
  void addTanks(String funLoc, List<dynamic> hangingUnitResponse) async {
    try {
      _tanks = await hangingUnitRpo.addTanks(funLoc, hangingUnitResponse);
    } catch (error) {
      rethrow;
    }
  }

  /// map json to hose objcet
  void addHoses(List<dynamic> extractedData) {
    final loadedHose = extractedData
        .map((e) => Hose.fromJson(e, extractedData.indexOf(e)))
        .toList();
    _hoseList = loadedHose;
  }

  /// extract unique hanging units objest as the json sent by backend
  /// contains an json map for each hose
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

  /// calculate total sales by looping on each hose
  /// total sales = ( quantity - hose calibration quantity ) * material unit price
  /// where quantity = enteredReading - lastReading
  void calculateTotal() {
    _totalSales = 0.0;
    for (var element in _hoseList) {
      _totalSales +=
          ((element.totalQuantity - element.calibration) * element.unitPrice);
    }

    notifyListeners();
  }

  /// In case of gas, fetch credit amount and quantity from backend
  /// then remove credit qty from actual total qty
  /// total sales = actual total qty * unit price for the first hose, as all gas hoses have same price
  /// the add credit amount to the total sales
  Future<bool> calaulateTotalSalesWithCredit() async {
    try {
      final responseData = await hangingUnitRpo.getCredit();

      _creditAmount = responseData['cAmount']!; // credit amount
      _mobileAmount = responseData['mAmount']!; // mobile amount

      double creditQty = responseData['cQty']!; // credit qty
      double mobileQty = responseData['mQty']!; // mobile qty

      // calculate actual total qty
      double actualTotalQty = calculateTotalQty();

      if (creditQty + mobileQty < actualTotalQty) {
        // remove credit qty from totalQty
        actualTotalQty -= (creditQty + mobileQty);

        _totalSales = actualTotalQty * _hoseList.first.unitPrice;
        _totalSales += (_creditAmount + _mobileAmount);
        notifyListeners();
        return true;
      } else {
        throw HttpException('creditError');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// calculate total qty
  double calculateTotalQty() =>
      _hoseList.fold(0.0, (sum, element) => sum + element.totalQuantity);

  /// validate hose where for each hose with entered reading
  /// the entred reading - last reading * unit price must be
  /// equal to entred amount - last amount
  List<Hose?> validateProducts() {
    final itemsWithIncorrectAmount = _hoseList
        .where((item) => item.enteredReading != 0.0)
        .where((item) =>
            (item.enteredReading - item.lastReading) * item.unitPrice !=
            (item.enteredAmount - item.lastAmount))
        .toList();

    return itemsWithIncorrectAmount.isEmpty ? [] : itemsWithIncorrectAmount;
  }

  /// validate tanks as for every shift, the end shift measurements must be
  /// entered for every tank
  List<Tank?> validateTanks() {
    final tanksWithoutEntries =
        _tanks.where((tank) => tank.shiftEnd == null).toList();
    return tanksWithoutEntries.isEmpty ? [] : tanksWithoutEntries;
  }
}
