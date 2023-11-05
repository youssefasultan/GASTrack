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
      var userData = await Shared.getUserdata();

      final response = await RequestBuilder().buildGetRequest(
          "GasoItemsSet?\$filter=FunctionalLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}'&");

      final responseData = json.decode(response.body);
      final extractedData = responseData['d']['results'] as List<dynamic>;

      if (extractedData.isEmpty) {
        throw ArgumentError("No Equipments Found.");
      }

      final List<Product> loadedProducts = [];

      for (var element in extractedData) {
        loadedProducts.add(
          Product(
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
          ),
        );
      }

      _items = loadedProducts;

      // create tanks based on material from items
      final List<Tank> loadedTanks = [];

      if (userData['shiftType'] == 'F') {
        var uniqueMaterials = <String>{};
        loadedProducts
            .where((element) => uniqueMaterials.add(element.material))
            .toList();

        for (var mat in uniqueMaterials) {
          loadedTanks.add(Tank(material: mat));
        }

        _tanks = loadedTanks;
      }

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
}
