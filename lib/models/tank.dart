import 'package:flutter/material.dart';

class Tank with ChangeNotifier {
  final String material;
  double quantity;
  double expectedQuantity;

  Tank({
    required this.material,
    this.expectedQuantity = 0.0,
    this.quantity = 0.0,
  });
}
