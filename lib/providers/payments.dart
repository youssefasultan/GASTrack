import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gasolina/helpers/data/request_builder.dart';

import 'payment.dart';
import 'product.dart';

class Payments with ChangeNotifier {
  List<Payment> _paymentsItems = [];
  double _total = 0.0;

  List<Payment> getPaymentsMethods() {
    return _paymentsItems;
  }

  double get getTotal {
    return _total;
  }

  Future<void> fetchPayments() async {
    try {
      final response = await RequestBuilder().buildGetRequest("GasoPayMSet?");

      final responseData = json.decode(response.body);
      final extractedData = responseData['d']['results'] as List<dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      final List<Payment> loadedPayments = [];

      for (var element in extractedData) {
        loadedPayments.add(Payment(
          icon: element['Icon'],
          paymentType: element['PaymentType'],
        ));
      }

      _paymentsItems = loadedPayments;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> uploadShift(List<Product> productList) async {
    try {
      return RequestBuilder()
          .postShiftRequest(productList, _paymentsItems, _total);
    } catch (error) {
      rethrow;
    }
  }

  void calculateTotal() {
    for (var method in _paymentsItems) {
      _total += method.amount;
    }

    notifyListeners();
  }
}
