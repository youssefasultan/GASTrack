import 'package:flutter/material.dart';

class Hose with ChangeNotifier {
  final String equipmentId;
  final String material;
  final String materialDesc;
  double lastReading;
  double lastAmount;
  double enteredReading;
  double enteredAmount;
  double totalQuantity;
  double totalAmount;
  double calibration;
  final double unitPrice;
  final int measuringPoint;
  final String measuringUnit;
  final String measuringPointDesc;
  final int index;
  final bool inActiveFlag;

  Hose({
    required this.material,
    required this.materialDesc,
    required this.lastReading,
    required this.lastAmount,
    this.enteredReading = 0.0,
    this.totalQuantity = 0.0,
    this.enteredAmount = 0.0,
    this.totalAmount = 0.0,
    this.calibration = 0.0,
    required this.unitPrice,
    required this.measuringUnit,
    required this.measuringPoint,
    required this.measuringPointDesc,
    required this.equipmentId,
    required this.index,
    required this.inActiveFlag,
  });

  bool calibrationValidation(double entredCalibrationAmount) {
    return entredCalibrationAmount > (enteredReading - lastReading);
  }

  bool amountValidation(double amount) {
    final diff = (enteredReading - lastReading) * unitPrice;
    final expectedAmount = lastAmount + diff;
    return amount != expectedAmount;
  }

  void calculateHoes() {
    totalAmount = (totalQuantity - calibration) * unitPrice;
    enteredAmount = lastAmount + totalAmount;

    notifyListeners();
  }

  factory Hose.fromJson(Map<String, dynamic> json, int index) {
    return Hose(
      material: json['Material'],
      materialDesc: json['MaterialDesc'],
      lastReading: double.parse(json['LastRead']),
      lastAmount: double.parse(json['LastAmount']),
      unitPrice: double.parse(json['PricingUnit']),
      measuringUnit: json['Measurmntrangeunit'],
      measuringPoint: int.parse(json['MeasuringPoint']),
      measuringPointDesc: json['MeasuringPointDesc'],
      equipmentId: json['Equipment'],
      index: index,
      inActiveFlag: json['InactiveFlag'] as bool,
    );
  }
   factory Hose.fromSavedJson(Map<String, dynamic> json) {
    return Hose(
      material: json['Material'],
      materialDesc: json['MaterialDesc'],
      lastReading: double.parse(json['LastRead']),
      lastAmount: double.parse(json['LastAmount']),
      unitPrice: double.parse(json['PricingUnit']),
      measuringUnit: json['Measurmntrangeunit'],
      measuringPoint: int.parse(json['MeasuringPoint']),
      measuringPointDesc: json['MeasuringPointDesc'],
      equipmentId: json['Equipment'],
      index: json['index'] as int,
      inActiveFlag: json['InactiveFlag'] as bool,
    );
  }
}
