import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../ui_widgets/dash_separator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hanging_unit_provider.dart';
import '../../providers/payments_provider.dart';

class ConfirmationWidget extends StatelessWidget {
  const ConfirmationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
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
            itemBuilder: (context, index) => ListTile(
              title: Text(
                productsList[index].measuringPointDesc,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                productsList[index].materialDesc,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${t.quantity} : ${productsList[index].enteredReading.toString()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${t.amount} : ${productsList[index].enteredAmount.toString()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
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
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  tankList[index].material,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Bebas',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${t.amount} : ${tankList[index].quantity.toString()}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${t.reading} : ${tankList[index].expectedQuantity.toString()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bebas',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
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
}
