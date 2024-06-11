import 'package:flutter/material.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';
import 'package:provider/provider.dart';

import 'hangingunit_list_tile.dart';
import 'tank_list_tile.dart';

class FuelTabBarLibrary extends StatefulWidget {
  final TabController tabController;
  const FuelTabBarLibrary({
    super.key,
    required this.tabController,
  });

  @override
  State<FuelTabBarLibrary> createState() => _FuelTabBarLibraryState();
}

class _FuelTabBarLibraryState extends State<FuelTabBarLibrary> {
  @override
  Widget build(BuildContext context) {
    final hangingUnitList = context.hangingUnitsProvider.getHangingUnits;
    final tanksList = context.hangingUnitsProvider.getTanks;

    return Expanded(
      child: TabBarView(
        controller: widget.tabController,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: hangingUnitList[index],
              child: const HangingUnitListTile(),
            ),
            itemCount: hangingUnitList.length,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: tanksList[index],
              child: const TankListTile(),
            ),
            itemCount: tanksList.length,
          ),
        ],
      ),
    );
  }
}
