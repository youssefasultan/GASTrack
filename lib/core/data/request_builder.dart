import 'dart:convert';
import 'dart:io';

import 'package:gas_track/core/constants/data_constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../helper/image_converter.dart';
import '../models/http_exception.dart';
import '../../features/payment/model/payment.dart';
import '../../features/home/model/hanging_unit.dart';
import '../../features/home/model/tank.dart';
import 'shared_pref/shared.dart';

class RequestBuilder {
  RequestBuilder._();
  static String? _token;
  static String? _cookie;

  static Future<http.Response> buildGetRequest(String entitySet) async {
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

  static Future<bool> postShiftRequest(
      List<HangingUnit> hangingUnitsList,
      List<Payment> paymentList,
      List<Tank> tankList,
      double total,
      String cashImg,
      List<String> visaImgs,
      bool endDay) async {
    int responseCode;
    try {
      await _getToken();

      responseCode = await _upload(
        _token!,
        _cookie!,
        hangingUnitsList,
        paymentList,
        total,
        tankList,
        cashImg,
        visaImgs,
        endDay,
      );
      return responseCode == HttpStatus.created;
    } catch (error) {
      throw HttpException(error.toString());
    }
  }

  static Future<void> _getToken() async {
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

  static Future<int> _upload(
      String token,
      String cookie,
      List<HangingUnit> hangingUnitsList,
      List<Payment> paymentList,
      double total,
      List<Tank> tankList,
      String cashImg,
      List<String> visaImgs,
      bool endDay) async {
    var userData = await Shared.getUserdata();
    String cashBase64String = '';
    List<String> visaBase64String = [];

    if (cashImg.isNotEmpty) {
      cashBase64String = await ImageConverter.imageToBase64(cashImg);
    }

    if (visaImgs.isNotEmpty) {
      visaBase64String = await ImageConverter.imageListToBase64String(visaImgs);
    }

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$kUsername:$kPassword'))}';
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'x-csrf-token': token,
      'cookie': cookie,
      'content-type': 'application/json',
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
      'EndDay': endDay ? 'X' : '',
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
                'ExpQuantity': '${tank.shiftEnd ?? 0.0}',
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

  static List<Map<String, dynamic>> getImageList(Map<String, String> userData,
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

  static List<Map<String, String>> getJsonObjects(
      List<HangingUnit> hangingUnitsList) {
    List<Map<String, String>> result = [];

    for (var hangingUnit in hangingUnitsList) {
      result.addAll(hangingUnit.toJson());
    }

    return result;
  }

  static List<CouponData> getCouponData(List<Payment> paymentList) {
    Coupon? coupon;

    List<CouponData> result = [];

    for (var payment in paymentList) {
      if (payment is Coupon) {
        coupon = payment;
      }
    }
    if (coupon != null) {
      var usedCoupons =
          coupon.couponsList.where((element) => element.count != 0).toList();

      result.addAll(usedCoupons);
    }

    return result;
  }
}
