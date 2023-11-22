import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/http_exception.dart';
import '../../models/payment.dart';
import '../../models/hanging_unit.dart';
import '../../models/tank.dart';
import 'shared.dart';

class RequestBuilder {
  String? _token;
  String? _cookie;

  Future<http.Response> buildGetRequest(String entitySet) async {
    var settings = await Shared.getSettings();
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${settings['username']}:${settings['password']}'))}';
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
      'sap-client': '700',
    };

    final url = Uri.parse(
        "http://${settings['ip']}:8001/sap/opu/odata/SAP/YGASOLINA_SRV/$entitySet\$format=json");

    return await http.get(
      url,
      headers: headers,
    );
  }

  Future<bool> postShiftRequest(List<HangingUnit> productList,
      List<Payment> paymentList, List<Tank> tankList, double total) async {
    int responseCode;
    try {
      await _getToken();

      responseCode = await _upload(
          _token!, _cookie!, productList, paymentList, total, tankList);
    } catch (error) {
      throw HttpException(error.toString());
    }

    return responseCode == HttpStatus.created;
  }

  Future<void> _getToken() async {
    var settings = await Shared.getSettings();

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${settings['username']}:${settings['password']}'))}';
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'x-csrf-token': 'fetch',
      'set-cookie': 'fetch',
      'sap-client': '700',
    };

    final url = Uri.parse(
        "https://${settings['ip']}:44301/sap/opu/odata/SAP/YGASOLINA_SRV/St_GASOKSet?");

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
  ) async {
    var settings = await Shared.getSettings();
    var userData = await Shared.getUserdata();

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${settings['username']}:${settings['password']}'))}';
    Map<String, String> headers = {
      'Authorization': basicAuth,
      'x-csrf-token': token,
      'cookie': cookie,
      'content-type': 'application/json',
      'sap-client': '700',
    };

    final url = Uri.parse(
        "https://${settings['ip']}:44301/sap/opu/odata/SAP/YGASOLINA_SRV/St_GASOKSet");

    List<Map<String, String>> getJsonObjects() {
      List<Map<String, String>> result = [];

      for (var hangingUnit in hangingUnitsList) {
        for (var hose in hangingUnit.toJson()) {
          result.add(hose);
        }
      }

      return result;
    }

    var body = json.encode({
      'ShiftDate': '${userData['shiftDate']}',
      'Shift': '${userData['shiftNo']}',
      'ShiftType': '${userData['shiftType']}',
      'ShiftTime': '${userData['shiftTime']}',
      'ShiftEndBy': '${userData['user']}',
      'ShiftLocation': '${userData['funLoc']}',
      'TotalAmount': '$total',
      'Currency': 'EGP',
      'BillingDoc': '',
      'GasokToGasop': getJsonObjects(),
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
                'Quantity': '${tank.quantity}',
                'ExpQuantity': '${tank.expectedQuantity}',
                'Uoms': 'L',
              })
          .toList(),
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response.statusCode;
  }
}
