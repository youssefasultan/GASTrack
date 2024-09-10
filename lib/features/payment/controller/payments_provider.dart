import 'package:flutter/material.dart';
import 'package:gas_track/core/data/repo/payment/payment_repo.dart';
import 'package:provider/provider.dart';

import '../model/payment.dart';
import '../model/summery.dart';
import '../../home/controller/hanging_unit_provider.dart';

class PaymentsProvider with ChangeNotifier {
  final paymentRepo = PaymentRepo();

  List<Payment> _paymentsItems = [];
  double _total = 0.0;
  double _creditAmount = 0.0;
  double _mobileAmount = 0.0;

  List<Summery> _summery = [];
  List<Map<String, dynamic>> _summeryTotals = [];

  String _cashRecipetImg = '';
  final List<String> _visaReciptsImg = [];

  PaymentsProvider(
      double totalSales, double creditAmount, double mobileAmount) {
    _total = totalSales;
    _creditAmount = creditAmount;
    _mobileAmount = mobileAmount;
  }

  List<Map<String, dynamic>> get getSummeryTotals {
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

  /// fetch end of day summry for all shif payments
  Future<void> getEndOfDaySummeryPayments() async {
    _summery = await paymentRepo.getSummery();
    _summeryTotals = calculateTotalSummery();

    notifyListeners();
  }

  /// calculate total for each payment type
  List<Map<String, dynamic>> calculateTotalSummery() {
    Map<String, double> sums = {};

    for (Summery payment in _summery) {
      String name = payment.paymentType;
      double value = payment.value;

      if (sums.containsKey(name)) {
        sums[name] = sums[name]! + value;
      } else {
        sums[name] = value;
      }
    }
    List<Map<String, dynamic>> result = [];
    sums.forEach((name, sum) {
      result.add({'name': name, 'value': sum});
    });

    return result;
  }

  /// fetch payment methods
  // if shift type is fuel(F) remove all payment methods except cash and visa
  // else if shift type is Gas(G) set the credit anount to payment with icon == 'CARD'
  // and add it to the end of the list
  // after that for the cash payment the value is set to total - credit total
  // then added to the end of the list
  Future<void> fetchPayments(String shiftType) async {
    try {
      _paymentsItems = await paymentRepo.fetchPayments(shiftType);

      if (shiftType == 'G') {
        // credit
        final Payment creditPayment = _paymentsItems
            .where(
              (element) => element.paymentType == 'ZUCP', // credit
            )
            .first;

        creditPayment.amount = _creditAmount;
        _paymentsItems.remove(creditPayment);
        _paymentsItems.add(creditPayment);

        // mobile
        final Payment mobilePayment = _paymentsItems
            .where(
              (element) => element.paymentType == 'ZMOB', // mobile stations
            )
            .first;

        mobilePayment.amount = _mobileAmount;
        _paymentsItems.remove(mobilePayment);
        _paymentsItems.add(mobilePayment);
      }

      // make cash payment at the end of payment list and set cash amount to total as default
      final Payment cashPayment = _paymentsItems
          .where(
            (element) => element.paymentType == 'ZCSH',// cash
          )
          .first;

      cashPayment.amount = _total - _creditAmount - _mobileAmount;
      _paymentsItems.remove(cashPayment);
      _paymentsItems.add(cashPayment);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // upload shift
  Future<bool> uploadShift(BuildContext context, bool endDay) async {
    try {
      final productsData =
          Provider.of<HangingUnitsProvider>(context, listen: false);
      final hangingUnitsList = productsData.getHangingUnits;
      final tankList = productsData.getTanks;

      return await paymentRepo.uploadShift(hangingUnitsList, _paymentsItems,
          tankList, _total, _cashRecipetImg, _visaReciptsImg, endDay);
    } catch (error) {
      rethrow;
    }
  }

  /// calculate total of coupons amount
  /// then calculate cash amount
  bool calculateCouponTotal() {
    for (var payment in _paymentsItems) {
      if (payment is Coupon) {
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

  // cash payment is dimmed, so it is calculated by removing other payments amount from total amount
  bool calculateCash() {
    double nonCashTotal = _paymentsItems
        .where((p) => p.icon != 'CASH')
        .fold(0, (sum, p) => sum + p.amount);

    for (var p in _paymentsItems) {
      if (p.icon == 'CASH') {
        final cashAmount = _total - nonCashTotal;

        if ((cashAmount) < 0) {
          return false;
        } else {
          p.updateAmount(cashAmount);
        }

        break;
      }
    }

    notifyListeners();

    return true;
  }

  /// validate that payments total amount is equal to total amount
  bool validatePayments() {
    double total = 0.0;
    for (var payment in _paymentsItems) {
      total += payment.amount;
    }

    return total != _total;
  }
}
