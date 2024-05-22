import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:gas_track/helpers/data/data_constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../models/http_exception.dart';
import '../../models/payment.dart';
import '../../models/hanging_unit.dart';
import '../../models/tank.dart';
import 'shared.dart';

class RequestBuilder {
  String? _token;
  String? _cookie;

  Future<http.Response> buildGetRequest(String entitySet) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$kUsername:$kPassword'))}';
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
      // 'sap-client': '100',
    };

    final url = Uri.parse(
        "https://$ipAddress:44301/sap/opu/odata/SAP/YGASOLINA_SRV/$entitySet\$format=json");

    return await http.get(
      url,
      headers: headers,
    );
  }

  Future<bool> postShiftRequest(
      List<HangingUnit> hangingUnitsList,
      List<Payment> paymentList,
      List<Tank> tankList,
      double total,
      String cashImg,
      List<String> visaImgs) async {
    int responseCode;
    try {
      await _getToken();

      responseCode = await _upload(_token!, _cookie!, hangingUnitsList,
          paymentList, total, tankList, cashImg, visaImgs);
    } catch (error) {
      throw HttpException(error.toString());
    }

    return responseCode == HttpStatus.created;
  }

  Future<void> _getToken() async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$kUsername:$kPassword'))}';
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'x-csrf-token': 'fetch',
      'set-cookie': 'fetch',
      // 'sap-client': '100',
    };

    final url = Uri.parse(
        "https://$ipAddress:44301/sap/opu/odata/SAP/YGASOLINA_SRV/St_GASOKSet?");

    final response = await http.get(
      url,
      headers: headers,
    );

    _token = response.headers['x-csrf-token'];
    _cookie = response.headers['set-cookie']?.split(',')[1];
  }

  Future<int> _upload(
    String token,
    String cookie,
    List<HangingUnit> hangingUnitsList,
    List<Payment> paymentList,
    double total,
    List<Tank> tankList,
    String cashImg,
    List<String> visaImgs,
  ) async {
    var userData = await Shared.getUserdata();
    String cashBase64String = '';
    List<String> visaBase64String = [];

    if (cashImg.isNotEmpty) {
      cashBase64String = await cashImageBase64(cashImg);
    }

    if (visaImgs.isNotEmpty) {
      visaBase64String = await visaImgsToBase64String(visaImgs);
    }

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$kUsername:$kPassword'))}';
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'x-csrf-token': token,
      'cookie': cookie,
      'content-type': 'application/json',
      // 'sap-client': '100',
    };

    final url = Uri.parse(
        "https://$ipAddress:44301/sap/opu/odata/SAP/YGASOLINA_SRV/St_GASOKSet");

    var body = json.encode({
      'ShiftDate': '${userData['shiftDate']}',
      'Shift': '${userData['shiftNo']}',
      'ShiftType': '${userData['shiftType']}',
      'ShiftTime': '${userData['shiftTime']}',
      'ShiftEndBy': '${userData['user']}',
      'ShiftEndByName': '${userData['name']}',
      'ShiftLocation': '${userData['funLoc']}',
      'TotalAmount': '$total',
      'Currency': 'EGP',
      'BillingDoc': '',
      'GasokToGasop': getJsonObjects(hangingUnitsList),
      'GasokToGasov': paymentList
          .map((pay) => {
                'Mandt': '',
                'ShiftLocation': '${userData['funLoc']}',
                'ShiftDate': '${userData['shiftDate']}',
                'Shift': '${userData['shiftNo']}',
                'ShiftType': '${userData['shiftType']}',
                'PaymentType': pay.paymentType,
                'PaymentValue': "${pay.amount}",
                'PaymentCurrency': "EGP",
              })
          .toList(),
      'GasokToGasot': tankList
          .map((tank) => {
                'Mandt': '',
                'ShiftLocation': '${userData['funLoc']}',
                'ShiftDate': '${userData['shiftDate']}',
                'Shift': '${userData['shiftNo']}',
                'ShiftType': '${userData['shiftType']}',
                'Material': tank.material,
                'FirstQuantity': '${tank.shiftStart}',
                'Quantity': '${tank.quantity}',
                'ExpQuantity': '${tank.shiftEnd}',
                'WaredQty': '${tank.waredQty}',
                'Uoms': 'L',
              })
          .toList(),
      'GasokToGasoc': getCouponData(paymentList)
          .map((e) => {
                'ShiftLocation': '${userData['funLoc']}',
                'ShiftDate': '${userData['shiftDate']}',
                'Shift': '${userData['shiftNo']}',
                'ShiftType': '${userData['shiftType']}',
                'Coupons': e.coupon,
                'CouponsValue': '${e.value}',
                'PaymentCurrency': 'EGP',
                'CouponsQty': e.count,
              })
          .toList(),
      'GasokToGasom': getImageList(userData, cashBase64String, visaBase64String)
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response.statusCode;
  }

  Future<List<String>> visaImgsToBase64String(List<String> visaImgs) async {
    List<String> visaBase64String = [];
    for (var img in visaImgs) {
      File imageFile = File(img);
      Uint8List bytes = await imageFile.readAsBytes();
      visaBase64String.add(base64.encode(bytes));
    }
    return visaBase64String;
  }

  Future<String> cashImageBase64(String cashImg) async {
    File imageFile = File(cashImg);
    Uint8List bytes = await imageFile.readAsBytes();
    String cashBase64String = base64.encode(bytes);
    return cashBase64String;
  }

  List<Map<String, dynamic>> getImageList(Map<String, String> userData,
      String cashImgSource, List<String> visaImgs) {
    final List<Map<String, dynamic>> result = [];
    final f = DateFormat('yyyyMMdd');
    final date = f.format(DateTime.now());

    // cashImg
    final cashImg = {
      'ShiftLocation': '${userData['funLoc']}',
      'ShiftDate': '${userData['shiftDate']}',
      'Shift': '${userData['shiftNo']}',
      'ShiftType': '${userData['shiftType']}',
      'Item': '1',
      'ImageObject':
          '${userData['funLoc']}#$date#${userData['shiftNo']}#${userData['shiftType']}#1',
      'Filename': 'فاتوره كاش',
      'Mimetype': 'png',
      'Value': cashImgSource,
    };

    result.add(cashImg);

    final visaMap = visaImgs
        .map((e) => {
              'ShiftLocation': '${userData['funLoc']}',
              'ShiftDate': '${userData['shiftDate']}',
              'Shift': '${userData['shiftNo']}',
              'ShiftType': '${userData['shiftType']}',
              'Item': '${visaImgs.indexOf(e) + 2}',
              'ImageObject':
                  '${userData['funLoc']}#$date#${userData['shiftNo']}#${userData['shiftType']}#${visaImgs.indexOf(e) + 2}',
              'Filename': 'فيزا ${visaImgs.indexOf(e)}',
              'Mimetype': 'png',
              'Value': e,
            })
        .toList();

    result.addAll(visaMap);

    return result;
  }

  List<Map<String, String>> getJsonObjects(List<HangingUnit> hangingUnitsList) {
    List<Map<String, String>> result = [];

    for (var hangingUnit in hangingUnitsList) {
      result.addAll(hangingUnit.toJson());
    }

    return result;
  }

  List<CouponData> getCouponData(List<Payment> paymentList) {
    Coupon? coupon;
    UnpaidCoupon? unpaidCoupon;
    List<CouponData> result = [];

    for (var payment in paymentList) {
      if (payment is Coupon) {
        coupon = payment;
      } else if (payment is UnpaidCoupon) {
        unpaidCoupon = payment;
      }
    }
    if (coupon != null) {
      var usedCoupons =
          coupon.couponsList.where((element) => element.count != 0).toList();

      result.addAll(usedCoupons);
    }

    if (unpaidCoupon != null) {
      var usedCoupons = unpaidCoupon.couponsList
          .where((element) => element.count != 0)
          .toList();
      result.addAll(usedCoupons);
    }

    return result;
  }
}
