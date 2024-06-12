import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:gas_track/core/view/ui/ui_constants.dart';
import 'package:gas_track/features/home/model/hose.dart';
import 'package:gas_track/features/home/model/tank.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../../ui/dash_separator.dart';

class ConfirmationWidget extends StatelessWidget {
  const ConfirmationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final shiftType = context.authProvider.getShiftType;
    final hangingUnitsData = context.hangingUnitsProviderWithNoListner;
    final productsList = hangingUnitsData.getHoseList;
    final tankList = hangingUnitsData.getTanks;
    final paymentData = context.paymentsProviderWithNoListner;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              context.translate.confirm,
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
                context.translate.dispenser,
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
                  return productItem(product, context.translate, shiftType);
                },
                itemCount: productsList.length,
              ),
            ),
            if (shiftType == 'F' && tankList.isNotEmpty) ...{
              const DashSeparator(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Text(
                  context.translate.tank,
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

                    return tankItem(tank, context.translate);
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
                    context.translate.total,
                    style: TextStyle(
                      fontFamily: 'Bebas',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.theme.primaryColor,
                    ),
                  ),
                  Text(
                    '${paymentData.getTotalCollection} ${context.translate.egp}',
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
            mainAxisAlignment: MainAxisAlignment.start,
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
            mainAxisAlignment: MainAxisAlignment.start,
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
                '${t.end} : ${tank.shiftEnd ?? 0.0}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${t.refil} : ${tank.waredQty}',
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
            mainAxisAlignment: MainAxisAlignment.start,
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
            mainAxisAlignment: MainAxisAlignment.start,
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
