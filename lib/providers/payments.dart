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

  void calculateTotal() {
    var total = 0.0;
    for (var method in _paymentsItems) {
      total += method.amount;
    }
    _total = total;
    notifyListeners();
  }
}
