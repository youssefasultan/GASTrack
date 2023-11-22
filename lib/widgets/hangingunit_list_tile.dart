import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hanging_unit.dart';
import 'hose_list_tile.dart';

class HangingUnitListTile extends StatefulWidget {
  const HangingUnitListTile({super.key});

  @override
  State<HangingUnitListTile> createState() => _HangingUnitListTileState();
}

class _HangingUnitListTileState extends State<HangingUnitListTile> {
  @override
  Widget build(BuildContext context) {
    final hangingUnit = Provider.of<HangingUnit>(context);
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          hangingUnit.equipmentDesc,
          style: TextStyle(
            fontSize: 18,
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
          SizedBox(
            width: double.infinity,
            height: 450,
            child: ListView.builder(
              itemExtent: 250,
              itemBuilder: (context, index) => ChangeNotifierProvider.value(
                value: hangingUnit.hoseList[index],
                child: const HoseListTile(),
              ),
              itemCount: hangingUnit.hoseList.length,
            ),
          )
        ],
      ),
    );
  }
}
