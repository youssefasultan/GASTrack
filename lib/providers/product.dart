import 'package:flutter/material.dart';

import '../helpers/data/constants.dart';

class Product with ChangeNotifier {
  final String equipment;
  final String equipmentDesc;
  final ProductCategory category;
  final String material;
  final String materialDesc;
  final String objectNumber;
  double currentReading;
  double enteredReading;
  double unitPrice;
  String measuringUnit;

  Product({
    required this.equipment,
    required this.equipmentDesc,
    required this.material,
    required this.materialDesc,
    required this.category,
    required this.currentReading,
    this.enteredReading = 0.0,
    required this.unitPrice,
    required this.measuringUnit,
    required this.objectNumber,
  });
}
