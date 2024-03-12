import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../helpers/view/ui/ui_constants.dart';
import '../../../providers/payments_provider.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var paymentData = Provider.of<PaymentsProvider>(context);
    var t = AppLocalizations.of(context)!;
    // ThemeData themeData = Theme.of(context);
    return Container(
      width: 100.w,
      height: 23.h,
      margin: EdgeInsets.all(1.h),
      padding: EdgeInsets.all(1.h),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        gradient: linerGradient,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 9.h,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.total,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${paymentData.getTotalCollection} ${t.egp}',
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 18.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
