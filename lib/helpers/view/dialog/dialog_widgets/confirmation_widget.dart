import 'package:flutter/material.dart';
import 'package:gas_track/helpers/view/ui/ui_constants.dart';
import 'package:gas_track/models/hose.dart';
import 'package:gas_track/models/tank.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../ui/dash_separator.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/hanging_unit_provider.dart';
import '../../../../providers/payments_provider.dart';

class ConfirmationWidget extends StatelessWidget {
  const ConfirmationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    // ThemeData themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final shiftType =
        Provider.of<AuthProvider>(context, listen: false).getShiftType;
    final hangingUnitsData =
        Provider.of<HangingUnitsProvider>(context, listen: false);
    final productsList = hangingUnitsData.getHoseList;
    final tankList = hangingUnitsData.getTanks;
    final paymentData = Provider.of<PaymentsProvider>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          t.confirm,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontFamily: 'Bebas',
          ),
        ),
        const DashSeparator(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            t.dispenser,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(
          width: double.maxFinite,
          height: shiftType == 'F' ? size.height * 0.3 : size.height * 0.5,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final product = productsList[index];
              return productItem(product, t);
            },
            itemCount: productsList.length,
          ),
        ),
        if (shiftType == 'F' && tankList.isNotEmpty) ...{
          const DashSeparator(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(
              t.tank,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            width: double.maxFinite,
            height: size.height * 0.2,
            child: ListView.builder(
              itemBuilder: (context, index) {
                final tank = tankList[index];

                return tankItem(tank, t);
              },
              itemCount: tankList.length,
            ),
          )
        },
        const DashSeparator(),
        Container(
          width: double.maxFinite,
          height: size.height * 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.total,
                style: TextStyle(
                  fontFamily: 'Bebas',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                '${paymentData.getTotalCollection} ${t.egp}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget tankItem(Tank tank, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: blueColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                '${t.fuel} : ${tank.material}',
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${t.amount} : ${tank.quantity.toString()}',
              )
            ],
          ),
          Column(
            children: [
              Text(
                '${t.start} : ${tank.shiftStart.toString()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.end} : ${tank.shiftEnd.toString()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.refil} : ${tank.waredQty.toString()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget productItem(Hose product, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: blueColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                product.measuringPointDesc,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                product.materialDesc,
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '${t.quantity} : ${product.totalQuantity.toString()} ${getUom(product.measuringUnit, t)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.amount} : ${product.totalAmount} ${t.egp}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.calibration} : ${product.calibration} ${getUom(product.measuringUnit, t)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String getUom(String mesruementUnit, AppLocalizations t) {
    switch (mesruementUnit) {
      case 'L':
        return t.liter;

      case 'M3':
        return t.m3;
      default:
        return '';
    }
  }
}
