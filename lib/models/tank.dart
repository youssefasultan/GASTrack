import 'package:flutter/material.dart';

class Tank with ChangeNotifier {
  final String material;
  double quantity;
  double shiftStart;
  double shiftEnd;

  Tank({
    required this.material,
    this.shiftEnd = 0.0,
    this.shiftStart = 0.0,
    this.quantity = 0.0,
  });
}
