import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'hose_list_tile.dart';

class HangingUnitListTile extends StatefulWidget {
  const HangingUnitListTile({super.key});

  @override
  State<HangingUnitListTile> createState() => _HangingUnitListTileState();
}

class _HangingUnitListTileState extends State<HangingUnitListTile> {
  @override
  Widget build(BuildContext context) {
    final hangingUnit = context.getHangingUnit;
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(1.h),
      child: ExpansionTile(
        title: Text(
          hangingUnit.equipmentDesc,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Bebas',
            color: themeData.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        expandedAlignment: Alignment.center,
        collapsedBackgroundColor: themeData.primaryColorLight,
        backgroundColor: themeData.primaryColorLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: hangingUnit.hoseList[index],
              child: const HoseListTile(),
            ),
            itemCount: hangingUnit.hoseList.length,
          )
        ],
      ),
    );
  }
}
