import 'dart:convert';

import 'package:flutter/material.dart';

import '../helpers/data/constants.dart';
import '../helpers/data/request_builder.dart';
import '../helpers/data/shared.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  bool isUpdated = false;
  double _total = 0.0;

  bool get dataUpdated {
    return isUpdated;
  }

  double get getTotalSales {
    return _total;
  }

  List<Product> getProductsPerCategory(ProductCategory productCategory) {
    return _items
        .where((product) => product.category == productCategory)
        .toList();
  }

  List<Product> getProducts() {
    return _items;
  }

  void updateProductsData() {
    for (var item in _items) {
      if (item.enteredReading != 0.0) {
        item.lastReading = item.enteredReading;
      }
    }

    isUpdated = true;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      var userData = await Shared.getUserdata();

      final response = await RequestBuilder().buildGetRequest(
          "GasoItemsSet?\$filter=FunctionalLocation eq '${userData['funLoc']}'&");

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
            category: getProductCategory(element['EquipmentDescription']),
            lastReading: double.parse(element['LastRead']),
            unitPrice: double.parse(element['PricingUnit']),
            measuringUnit: element['Measurmntrangeunit'],
            objectNumber: element['ObjectNumber'],
          ),
        );
      }

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  ProductCategory getProductCategory(String equipmentDesc) {
    if (equipmentDesc.contains('GAS')) {
      return ProductCategory.Gas;
    } else if (equipmentDesc.contains('benzen')) {
      return ProductCategory.Fuel;
    }

    // return ProductCategory.Oil;
    throw ArgumentError("Could not determine product category.");
  }

  void calculateTotal() {
    for (var element in _items) {
      _total += (element.quantity * element.unitPrice);
    }
    notifyListeners();
  }
}
