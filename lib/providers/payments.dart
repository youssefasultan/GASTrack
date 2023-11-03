import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/data/request_builder.dart';
import 'payment.dart';
import 'products.dart';

class Payments with ChangeNotifier {
  List<Payment> _paymentsItems = [];
  double _total = 0.0;

  List<Payment> getPaymentsMethods() {
    return _paymentsItems;
  }

  double get getTotalCollection {
    return _total;
  }

  Map<String, String> getEndOfDaySummeryPayments() {
    // TODO: return all day total for each payment type, total collection and total sales
    return {
      "collection": "",
      "sales": "",
      "cash": "",
      "card": "",
      "coupon": ""
    };
  }

  Future<void> fetchPayments() async {
    try {
      // get payment methods
      var response = await RequestBuilder().buildGetRequest("GasoPayMSet?");

      var responseData = json.decode(response.body);
      var extractedData = responseData['d']['results'] as List<dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      final List<Payment> loadedPayments = [];

      for (var element in extractedData) {
        if (element['Icon'] == 'COUPON') {
          loadedPayments.add(Coupon(
            icon: element['Icon'],
            paymentType: element['PaymentType'],
          ));
        } else {
          loadedPayments.add(Payment(
            icon: element['Icon'],
            paymentType: element['PaymentType'],
          ));
        }
      }

      // get coupons
      response = await RequestBuilder().buildGetRequest("YGasoCouponsSet?");

      responseData = json.decode(response.body);
      extractedData = responseData['d']['results'] as List<dynamic>;

      Coupon? coupon;

      for (var payment in loadedPayments) {
        if (payment is Coupon) {
          coupon = payment;
          break;
        }
      }
      for (var element in extractedData) {
        coupon!.couponsList.add(
          CouponData(
            coupon: element['Coupons'],
            couponDesc: element['CouponsDesc'],
            value: double.parse(element['Value']),
            currency: element['Currency'],
          ),
        );
      }

      _paymentsItems = loadedPayments;
      _total = 0.0;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> uploadShift(BuildContext context) async {
    try {
      final productsData = Provider.of<Products>(context, listen: false);
      final productsList = productsData.getProducts();
      return RequestBuilder()
          .postShiftRequest(productsList, _paymentsItems, _total);
    } catch (error) {
      rethrow;
    }
  }

  void calculateCouponTotal() {
    for (var payment in _paymentsItems) {
      if (payment is Coupon) {
        payment.amount = 0.0;
        for (var coupon in payment.couponsList) {
          payment.amount += coupon.amount;
        }
      }
    }
    calculateTotal();
    notifyListeners();
  }

  void calculateCash(BuildContext context) {
    final productsData = Provider.of<Products>(context, listen: false);
    final totalSales = productsData.getTotalSales;
    double totalVisaCoupon = 0.0;
    for (var payment in _paymentsItems) {
      if (payment.icon != 'CASH') {
        totalVisaCoupon += payment.amount;
      }
    }

    for (var payment in _paymentsItems) {
      if (payment.icon == 'CASH') {
        payment.amount = totalSales - totalVisaCoupon;
      }
    }
    notifyListeners();
  }

  void calculateTotal() {
    var total = 0.0;
    for (var method in _paymentsItems) {
      total += method.amount;
    }
    _total = total;
    notifyListeners();
  }
}
