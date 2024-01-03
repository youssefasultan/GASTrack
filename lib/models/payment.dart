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

class CouponData with ChangeNotifier {
  String coupon;
  String couponDesc;
  double value;
  int count;
  double amount;
  String currency;
  String businessPartner;
  CouponData({
    required this.coupon,
    required this.couponDesc,
    required this.value,
    required this.currency,
    required this.businessPartner,
    this.amount = 0.0,
    this.count = 0,
  });
}

class Coupon extends Payment {
  List<CouponData> couponsList;
  Coupon({
    required super.icon,
    required super.paymentType,
    required this.couponsList,
  });
}

class UnpaidCoupon extends Payment {
  List<CouponData> couponsList;
  UnpaidCoupon(
      {required super.icon,
      required super.paymentType,
      required this.couponsList});
}
