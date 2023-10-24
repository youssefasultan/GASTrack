import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gasolina/helpers/data/request_builder.dart';

import '../helpers/data/constants.dart';
import '../helpers/data/shared.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  bool isUpdated = false;

  bool get dataUpdated {
    return isUpdated;
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
        item.currentReading = item.enteredReading;
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
        return;
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
            currentReading: double.parse(element['MeasuringPoint']),
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

    return ProductCategory.Oil;
  }
}
