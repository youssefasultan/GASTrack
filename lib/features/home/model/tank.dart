import 'package:flutter/material.dart';

class Tank with ChangeNotifier {
  final String material;
  double quantity;
  double amount;
  double shiftStart;
  double? shiftEnd;
  final double unitPrice;
  double waredQty;

  Tank({
    required this.material,
    required this.unitPrice,
    this.shiftEnd,
    required this.shiftStart,
    this.quantity = 0.0,
    this.amount = 0.0,
    this.waredQty = 0.0,
  });

  void setEndSift(double? shiftEnd) {
    this.shiftEnd = shiftEnd;
    notifyListeners();
  }

  void setWaredQty(double waredQty) {
    this.waredQty = waredQty;
    notifyListeners();
  }

  void setStartShift(double shiftStart) {
    this.shiftStart = shiftStart;
    notifyListeners();
  }
}
