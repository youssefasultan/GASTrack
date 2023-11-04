import 'dart:convert';

import 'package:flutter/material.dart';

import '../helpers/data/request_builder.dart';
import '../helpers/data/shared.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  double _total = 0.0;

  double get getTotalSales {
    return _total;
  }

  List<Product> getProducts() {
    return _items;
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

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  void calculateTotal() {
    _total = 0.0;
    for (var element in _items) {
      _total += (element.quantity * element.unitPrice);
    }
    notifyListeners();
  }
}
