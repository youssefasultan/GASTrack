import 'package:flutter/material.dart';

class Hose with ChangeNotifier {
  final String equipmentId;
  final String material;
  final String materialDesc;
  double lastReading;
  double lastAmount;
  double enteredReading;
  double enteredAmount;
  double quantity;
  final double unitPrice;
  final int measuringPoint;
  final String measuringUnit;
  final String measuringPointDesc;

  Hose(
      {required this.material,
      required this.materialDesc,
      required this.lastReading,
      required this.lastAmount,
      this.enteredReading = 0.0,
      this.quantity = 0.0,
      this.enteredAmount = 0.0,
      required this.unitPrice,
      required this.measuringUnit,
      required this.measuringPoint,
      required this.measuringPointDesc,
      required this.equipmentId});
}
