import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/data/request_builder.dart';
import 'payment.dart';
import 'products.dart';

class Payments with ChangeNotifier {
  List<Payment> _paymentsItems = [];
  double _total = 0.0;

  Payments(double totalSales) {
    _total = totalSales;
  }

  List<Payment> get getPaymentsMethods {
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

  Future<void> fetchPayments(String shiftType) async {
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
        final paymentType = element['PaymentType'];
        final icon = element['Icon'];
        final isCoupon = icon == 'COUPON';

        if (shiftType == 'G' && isCoupon) {
          loadedPayments.add(Coupon(
            icon: icon,
            paymentType: paymentType,
          ));
        } else if (shiftType == 'G' && !isCoupon) {
          loadedPayments.add(Payment(
            icon: icon,
            paymentType: paymentType,
          ));
        } else if (!isCoupon) {
          loadedPayments.add(Payment(
            icon: icon,
            paymentType: paymentType,
          ));
        }
      }

      // get coupons
      if (shiftType == 'G') {
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
      }

      _paymentsItems = loadedPayments;

      // make cash payment at the end of payment list
      final Payment cashPayment = _paymentsItems
          .where(
            (element) => element.icon == 'CASH',
          )
          .first;
      _paymentsItems.remove(cashPayment);
      _paymentsItems.add(cashPayment);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> uploadShift(BuildContext context) async {
    try {
      final productsData = Provider.of<Products>(context, listen: false);
      final productsList = productsData.getProducts;
      final tankList = productsData.getTanks;
      return await RequestBuilder()
          .postShiftRequest(productsList, _paymentsItems, tankList, _total);
    } catch (error) {
      rethrow;
    }
  }

  void calculateCouponTotal() {
    for (var payment in _paymentsItems) {
      if (payment is Coupon) {
        payment.amount =
            payment.couponsList.fold(0.0, (sum, coupon) => sum + coupon.amount);
      }
    }

    calculateCash();
    notifyListeners();
  }

  void calculateCash() {
    double totalVisaCoupon = _paymentsItems
        .where((p) => p.icon != 'CASH')
        .fold(0, (sum, p) => sum + p.amount);

    for (var p in _paymentsItems) {
      if (p.icon == 'CASH') {
        p.amount = _total - totalVisaCoupon;
      }
    }

    notifyListeners();
  }

  bool validatePayments() {
    double total = 0.0;
    for (var payment in _paymentsItems) {
      total += payment.amount;
    }

    return total == 0.0;
  }
}
