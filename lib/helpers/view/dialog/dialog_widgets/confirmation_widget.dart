import 'package:flutter/material.dart';
import 'package:gas_track/helpers/view/ui/ui_constants.dart';
import 'package:gas_track/models/hose.dart';
import 'package:gas_track/models/tank.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../../ui/dash_separator.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/hanging_unit_provider.dart';
import '../../../../providers/payments_provider.dart';

class ConfirmationWidget extends StatelessWidget {
  const ConfirmationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    final shiftType =
        Provider.of<AuthProvider>(context, listen: false).getShiftType;
    final hangingUnitsData =
        Provider.of<HangingUnitsProvider>(context, listen: false);
    final productsList = hangingUnitsData.getHoseList;
    final tankList = hangingUnitsData.getTanks;
    final paymentData = Provider.of<PaymentsProvider>(context, listen: false);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              t.confirm,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontFamily: 'Bebas',
              ),
            ),
            const DashSeparator(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                t.dispenser,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(
              width: 90.w,
              height: shiftType == 'F' ? 30.h : 45.h,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final product = productsList[index];
                  return productItem(product, t, shiftType);
                },
                itemCount: productsList.length,
              ),
            ),
            if (shiftType == 'F' && tankList.isNotEmpty) ...{
              const DashSeparator(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Text(
                  t.tank,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(
                width: 90.w,
                height: 20.h,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final tank = tankList[index];

                    return tankItem(tank, t);
                  },
                  itemCount: tankList.length,
                ),
              ),
            } else ...{
              const DashSeparator(),
            },
            Container(
              width: double.maxFinite,
              height: shiftType == 'F' ? 10.h : 20.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.total,
                    style: TextStyle(
                      fontFamily: 'Bebas',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    '${paymentData.getTotalCollection} ${t.egp}',
                    style: TextStyle(
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget tankItem(Tank tank, AppLocalizations t) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      margin: EdgeInsets.symmetric(vertical: 1.h),
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
                style: TextStyle(
                  fontSize: 12.sp,
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
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.end} : ${tank.shiftEnd.toString()}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.refil} : ${tank.waredQty.toString()}',
                style: TextStyle(
                  fontSize: 12.sp,
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

  Widget productItem(Hose product, AppLocalizations t, String shiftType) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      margin: EdgeInsets.symmetric(vertical: 1.h),
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
                style: TextStyle(
                  fontSize: 12.sp,
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
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.amount} : ${product.totalAmount} ${t.egp}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (shiftType == 'F')
                Text(
                  '${t.calibration} : ${product.calibration} ${getUom(product.measuringUnit, t)}',
                  style: TextStyle(
                    fontSize: 12.sp,
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
