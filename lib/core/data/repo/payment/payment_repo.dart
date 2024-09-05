import 'dart:convert';

import 'package:gas_track/core/data/request_builder.dart';
import 'package:gas_track/core/data/shared_pref/shared.dart';
import 'package:gas_track/features/home/model/hanging_unit.dart';
import 'package:gas_track/features/home/model/tank.dart';
import 'package:gas_track/features/payment/model/payment.dart';
import 'package:gas_track/features/payment/model/summery.dart';

class PaymentRepo {
  PaymentRepo();

  Future<List<Payment>> fetchPayments(String shiftType) async {
    try {
      // get payment methods
      var response = await RequestBuilder.buildGetRequest(
          "GasoPayMSet?\$filter=ShiftType eq '$shiftType'&");

      var responseData = json.decode(response.body);
      var extractedData = responseData['d']['results'] as List<dynamic>;
      if (extractedData.isEmpty) {
        throw ArgumentError("No Payment Methods Found");
      }
      final List<Payment> loadedPayments = [];

      String sysDate = extractedData.first['Sdate'];
      await Shared.saveSystemDate(sysDate);

      for (var element in extractedData) {
        final paymentType = element['PaymentType'];
        final paymentName = element['PaymentTextAr'];
        final icon = element['Icon'];
        final isCoupon = icon == 'COUPON';

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
        response = await RequestBuilder.buildGetRequest("YGasoCouponsSet?");

        responseData = json.decode(response.body);
        extractedData = responseData['d']['results'] as List<dynamic>;

        Coupon? coupon;

        for (var payment in loadedPayments) {
          if (payment is Coupon) {
            coupon = payment;
          }
        }

        for (var element in extractedData) {
          coupon!.couponsList.add(
            CouponData(
              coupon: element['Coupons'],
              couponDesc: element['CouponsDesc'],
              value: double.parse(element['Value']),
              currency: element['Currency'],
              businessPartner: element['BusinessPartner'],
            ),
          );
        }
      }

      return loadedPayments;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Summery>> getSummery() async {
    try {
      // return all day total for each payment type, total collection and total sales
      final userData = await Shared.getUserdata();

      var response = await RequestBuilder.buildGetRequest(
          "GasAdminSet?\$filter=ShiftLocation eq '${userData['funLoc']}' and ShiftType eq '${userData['shiftType']}' and ShiftDate eq datetime'${userData['formattedDate']}T00:00:00'&");

      var responseData = json.decode(response.body);
      var extractedData = responseData['d']['results'] as List<dynamic>;

      return extractedData.map((e) {
        return Summery(
          shift: e['Shift'],
          paymentType: e['PaymentTextEg'],
          value: double.parse(e['PaymentValue']),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> uploadShift(
      List<HangingUnit> hangingUnitsList,
      List<Payment> payments,
      List<Tank> tankList,
      double total,
      String cashImg,
      List<String> visaImgs,
      bool endDay) async {
    try {
      return await RequestBuilder.postShiftRequest(hangingUnitsList, payments,
          tankList, total, cashImg, visaImgs, endDay);
    } catch (e) {
      rethrow;
    }
  }
}
