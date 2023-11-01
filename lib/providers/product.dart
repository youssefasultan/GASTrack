import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String equipment;
  final String equipmentDesc;
  final String material;
  final String materialDesc;
  final String objectNumber;
  double lastReading;
  double lastAmount;
  double enteredReading;
  double enteredAmount;
  double quantity;
  double unitPrice;
  int measuringPoint;
  String measuringUnit;

  Product({
    required this.equipment,
    required this.equipmentDesc,
    required this.material,
    required this.materialDesc,
    required this.lastReading,
    required this.lastAmount,
    this.enteredReading = 0.0,
    this.quantity = 0.0,
    this.enteredAmount = 0.0,
    required this.unitPrice,
    required this.measuringUnit,
    required this.objectNumber,
    required this.measuringPoint,
  });
}
