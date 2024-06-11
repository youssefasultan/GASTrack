import 'package:flutter/material.dart';
import 'package:gas_track/features/home/model/hose.dart';

class HangingUnit with ChangeNotifier {
  final String shiftLoc;
  final String shiftDate;
  final String shiftNo;
  final String shiftType;
  final String equipment;
  final String equipmentDesc;
  final String objectNumber;
  final List<Hose> hoseList;

  HangingUnit(
    this.hoseList, {
    required this.equipment,
    required this.equipmentDesc,
    required this.objectNumber,
    required this.shiftLoc,
    required this.shiftDate,
    required this.shiftNo,
    required this.shiftType,
  });

  List<Map<String, String>> toJson() {
    List<Map<String, String>> result = [];

    for (var hose in hoseList) {
      result.add(
        {
          'Mandt': '',
          'ShiftLocation': shiftLoc,
          'ShiftDate': shiftDate,
          'Shift': shiftNo,
          'ShiftType': shiftType,
          'GasShiftItem': ((hose.index + 1) * 10).toString().padLeft(6, '0'),
          'Equipment': equipment,
          'ObjectNumber': objectNumber,
          'MeasuringPoint': '${hose.measuringPoint}',
          'Measurmntrangeunit': hose.measuringUnit,
          'Material': hose.material,
          'Quantity': '${hose.totalQuantity - hose.calibration}',
          'ExpQuantity':
              '${hose.enteredReading == 0.0 ? hose.lastReading : hose.enteredReading}',
          'Uoms': hose.measuringUnit,
          'PricingUnit': '${hose.unitPrice}',
          'ExpAmount':
              '${hose.enteredAmount == 0.0 ? hose.lastAmount : hose.enteredAmount}',
          'Currency': 'EGP',
          'CalibrQty': '${hose.calibration}',
        },
      );
    }

    return result;
  }

  factory HangingUnit.fromJson(
      Map<String, dynamic> json, Map<String, String> userData) {
    return HangingUnit(
      [],
      equipmentDesc: json['EquipmentDescription'],
      objectNumber: json['ObjectNumber'],
      equipment: json['Equipment'],
      shiftLoc: userData['funLoc']!,
      shiftDate: userData['shiftDate']!,
      shiftNo: userData['shiftNo']!,
      shiftType: userData['shiftType']!,
    );
  }
}
