import 'package:flutter/material.dart';
import 'package:gas_track/models/hose.dart';

class HangingUnit with ChangeNotifier {
  final String equipment;
  final String equipmentDesc;
  final String objectNumber;
  final List<Hose> hoseList;

  HangingUnit(this.hoseList, {
    required this.equipment,
    required this.equipmentDesc,
    required this.objectNumber,
  });
}
