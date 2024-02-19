import 'package:flutter/material.dart';

class Tank with ChangeNotifier {
  final String material;
  double quantity;
  double amount;
  double shiftStart;
  double shiftEnd;
  final double unitPrice;

  Tank({
    required this.material,
    required this.unitPrice,
    this.shiftEnd = 0.0,
    this.shiftStart = 0.0,
    this.quantity = 0.0,
    this.amount = 0.0,
  });
}
