import 'dart:convert';

import 'package:flutter/material.dart';

import '../helpers/data/request_builder.dart';
import '../helpers/data/shared.dart';
import 'product.dart';
import 'tank.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  List<Tank> _tanks = [];

  double _total = 0.0;

  double get getTotalSales {
    return _total;
  }

  List<Product> get getProducts {
    return _items;
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

      final loadedProducts = extractedData.map((element) {
        return Product(
          equipment: element['Equipment'],
          equipmentDesc: element['EquipmentDescription'],
          material: element['Material'],
          materialDesc: element['MaterialDesc'],
          lastReading: double.parse(element['LastRead']),
          unitPrice: double.parse(element['PricingUnit']),
          measuringUnit: element['Measurmntrangeunit'],
          objectNumber: element['ObjectNumber'],
          measuringPoint: int.parse(element['MeasuringPoint']),
          lastAmount: 50.0,
        );
      }).toList();

      _items = loadedProducts;

      final loadedTanks = userData['shiftType'] == 'F'
          ? loadedProducts
              .map((product) => Tank(material: product.material))
              .toList()
          : [] as List<Tank>;

      _tanks = loadedTanks;

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  void calculateTankQuantity() {
    // calaculate tank quantity
    if (_tanks.isNotEmpty) {
      for (var tank in _tanks) {
        final productsList = _items
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
    for (var element in _items) {
      _total += (element.quantity * element.unitPrice);
    }

    notifyListeners();
  }

  Product? validateProducts() {
    final itemsWithIncorrectAmount = _items
        .where(
            (item) => item.enteredReading != 0.0 && item.enteredAmount != 0.0)
        .where((item) =>
            (item.enteredReading - item.lastReading) * item.unitPrice !=
            (item.enteredAmount - item.lastAmount))
        .toList();

    return itemsWithIncorrectAmount.isEmpty
        ? null
        : itemsWithIncorrectAmount.first;
  }
}
