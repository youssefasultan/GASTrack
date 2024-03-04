import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/data/request_builder.dart';
import '../helpers/data/shared.dart';
import '../models/payment.dart';
import '../models/summery.dart';
import 'hanging_unit_provider.dart';

class PaymentsProvider with ChangeNotifier {
  List<Payment> _paymentsItems = [];
  double _total = 0.0;
  List<Summery> _summery = [];
  Map<String, double> _summeryTotals = {};

  String _cashRecipetImg = '';
  final List<String> _visaReciptsImg = [];

  PaymentsProvider(double totalSales) {
    _total = totalSales;
  }

  Map<String, double> get getSummeryTotals {
    return _summeryTotals;
  }

  List<Payment> get getPaymentsMethods {
    return _paymentsItems;
  }

  double get getTotalCollection {
    return _total;
  }

  List<Summery> get getSummery {
    return _summery;
  }

  String get getCashRecipetImg {
    return _cashRecipetImg;
  }

  void setCashRecipetImg(String path) {
    _cashRecipetImg = path;
    notifyListeners();
  }

  void removeImgPathFromList(String path) {
    _visaReciptsImg.removeWhere((element) => element == path);
    notifyListeners();
  }

  List<String> get getVisaReciptsImg {
    return _visaReciptsImg;
  }

  void addVisaRecipets(List<String> paths) {
    _visaReciptsImg.addAll(paths);
    notifyListeners();
  }

  Future<void> getEndOfDaySummeryPayments() async {
    // return all day total for each payment type, total collection and total sales
    final userData = await Shared.getUserdata();

    var response = await RequestBuilder().buildGetRequest(
        "GasAdminSet?\$filter=ShiftLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}'&");

    var responseData = json.decode(response.body);
    var extractedData = responseData['d']['results'] as List<dynamic>;

    final loadedSummery = extractedData.map((e) {
      return Summery(
        shift: e['Shift'],
        paymentType: e['PaymentTextEg'],
        value: double.parse(e['PaymentValue']),
      );
    }).toList();
    _summery = loadedSummery;
    _summeryTotals = calculateTotalSummery();

    notifyListeners();
  }

  Map<String, double> calculateTotalSummery() {
    var totalCash = 0.0;
    var totalCard = 0.0;
    var totalCoupon = 0.0;
    var totalUnpaid = 0.0;
    for (var payment in _summery) {
      switch (payment.paymentType.toLowerCase()) {
        case 'visa':
          totalCard += payment.value;
          break;
        case 'cash':
          totalCash += payment.value;
          break;

        case 'coupon':
          totalCoupon += payment.value;
          break;
        case 'unpaid coupons':
          totalUnpaid += payment.value;
          break;
      }
    }

    return {
      'Cash': totalCash,
      'Visa': totalCard,
      'Coupon': totalCoupon,
      'Unpaid Coupons': totalUnpaid,
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
        final paymentName = element['PaymentTextAr'];
        final icon = element['Icon'];
        final isCoupon = icon == 'COUPON';
        final isCard = icon == 'CARD';

        if (shiftType == 'G') {
          if (isCoupon) {
            loadedPayments.insert(
              0,
              Coupon(
                icon: icon,
                paymentType: paymentType,
                paymentName: paymentName,
                couponsList: [],
              ),
            );
          } else if (isCard) {
            loadedPayments.insert(
              1,
              UnpaidCoupon(
                icon: icon,
                paymentType: paymentType,
                paymentName: paymentName,
                couponsList: [],
              ),
            );
          } else {
            loadedPayments.add(Payment(
              icon: icon,
              paymentType: paymentType,
              paymentName: paymentName,
            ));
          }
        } else {
          loadedPayments.add(Payment(
            icon: icon,
            paymentType: paymentType,
            paymentName: paymentName,
          ));
        }
      }

      // get coupons
      if (shiftType == 'G') {
        response = await RequestBuilder().buildGetRequest("YGasoCouponsSet?");

        responseData = json.decode(response.body);
        extractedData = responseData['d']['results'] as List<dynamic>;

        Coupon? coupon;
        UnpaidCoupon? unpaidCoupon;

        for (var payment in loadedPayments) {
          if (payment is Coupon) {
            coupon = payment;
          } else if (payment is UnpaidCoupon) {
            unpaidCoupon = payment;
          }
        }

        for (var element in extractedData) {
          bool isUnPaidCoupon =
              element['BusinessPartner'].toString().isNotEmpty;

          if (isUnPaidCoupon) {
            unpaidCoupon!.couponsList.add(
              CouponData(
                  coupon: element['Coupons'],
                  couponDesc: element['CouponsDesc'],
                  value: double.parse(element['Value']),
                  currency: element['Currency'],
                  businessPartner: element['BusinessPartner']),
            );
          } else {
            coupon!.couponsList.add(
              CouponData(
                  coupon: element['Coupons'],
                  couponDesc: element['CouponsDesc'],
                  value: double.parse(element['Value']),
                  currency: element['Currency'],
                  businessPartner: element['BusinessPartner']),
            );
          }
        }
      }

      _paymentsItems = loadedPayments;

      if (shiftType == 'F') {
        _paymentsItems.removeWhere(
            (element) => element.icon == 'COUPON' || element.icon == 'CARD');
      }

      // make cash payment at the end of payment list and set cash amount to total as default
      final Payment cashPayment = _paymentsItems
          .where(
            (element) => element.icon == 'CASH',
          )
          .first;

      if (shiftType == 'G') cashPayment.amount = _total;
      _paymentsItems.remove(cashPayment);
      _paymentsItems.add(cashPayment);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> uploadShift(BuildContext context) async {
    try {
      final productsData =
          Provider.of<HangingUnitsProvider>(context, listen: false);
      final hangingUnitsList = productsData.getHangingUnits;
      final tankList = productsData.getTanks;


      return await RequestBuilder()
          .postShiftRequest(hangingUnitsList, _paymentsItems, tankList, _total, _cashRecipetImg, _visaReciptsImg);
    } catch (error) {
      rethrow;
    }
  }

  bool calculateCouponTotal() {
    for (var payment in _paymentsItems) {
      if (payment is Coupon) {
        payment.amount =
            payment.couponsList.fold(0.0, (sum, coupon) => sum + coupon.amount);
      } else if (payment is UnpaidCoupon) {
        payment.amount =
            payment.couponsList.fold(0.0, (sum, coupon) => sum + coupon.amount);
      }
    }

    if (calculateCash()) {
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool calculateCash() {
    double totalVisaCoupon = _paymentsItems
        .where((p) => p.icon != 'CASH')
        .fold(0, (sum, p) => sum + p.amount);

    for (var p in _paymentsItems) {
      if (p.icon == 'CASH') {
        p.amount = _total - totalVisaCoupon;

        if (p.amount < 0) {
          return false;
        }
      }
    }

    notifyListeners();

    return true;
  }

  bool validatePayments() {
    double total = 0.0;
    for (var payment in _paymentsItems) {
      total += payment.amount;
    }

    return total != _total;
  }
}
