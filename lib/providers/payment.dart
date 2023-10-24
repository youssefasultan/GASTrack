import 'package:flutter/material.dart';

class Payment with ChangeNotifier {
  String paymentType;
  double amount;
  String icon;

  Payment({
    required this.icon,
    required this.paymentType,
    this.amount = 0.0,
  });
}
