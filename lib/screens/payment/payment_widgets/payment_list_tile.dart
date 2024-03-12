import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gas_track/helpers/view/dialog/dialog_builder.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../models/payment.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/payments_provider.dart';
import 'coupon_list_tile.dart';

class PaymentTile extends StatefulWidget {
  const PaymentTile({super.key});

  @override
  State<PaymentTile> createState() => _PaymentTileState();
}

class _PaymentTileState extends State<PaymentTile> {
  late AppLocalizations t;
  late TextEditingController amountController;

  @override
  void initState() {
    amountController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  IconData? getIcon(String paymentType) {
    switch (paymentType) {
      case 'COUPON':
        return Icons.card_membership;
      case 'VISA':
        return Icons.payment;
      case 'CASH':
        return Icons.monetization_on_sharp;
      case 'CARD':
        return Icons.no_accounts_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);

    final payment = Provider.of<Payment>(context);
    final payments = Provider.of<PaymentsProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    amountController.text =
        payment.amount == 0 ? '' : payment.amount.toString();

    if (auth.getShiftType == 'G' && payment is Coupon) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        child: ExpansionTile(
          key: Key(payment.paymentType),
          title: Text(
            payment.paymentName,
            style: TextStyle(
              fontFamily: 'Bebas',
              color: Theme.of(context).primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: themeData.primaryColorLight,
          collapsedBackgroundColor: themeData.primaryColorLight,
          expandedAlignment: Alignment.center,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payment.couponsList.length,
              itemBuilder: (context, index) => ChangeNotifierProvider.value(
                value: payment.couponsList[index],
                child: const CouponListTile(),
              ),
            )
          ],
        ),
      );
    } else if (auth.getShiftType == 'G' && payment is UnpaidCoupon) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        child: ExpansionTile(
          key: Key(payment.paymentType),
          title: Text(
            payment.paymentName,
            style: TextStyle(
              fontFamily: 'Bebas',
              color: Theme.of(context).primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: themeData.primaryColorLight,
          collapsedBackgroundColor: themeData.primaryColorLight,
          expandedAlignment: Alignment.center,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payment.couponsList.length,
              itemBuilder: (context, index) => ChangeNotifierProvider.value(
                value: payment.couponsList[index],
                child: const CouponListTile(),
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        child: ListTile(
          title: Text(
            payment.paymentName,
            style: TextStyle(
              fontFamily: 'Bebas',
              color: themeData.primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: SizedBox(
            width: 60.w,
            child: Focus(
              onFocusChange: (value) {
                if (!value) {
                  setState(() {
                    if (amountController.text.isEmpty) {
                      payment.amount = 0;
                    } else {
                      payment.amount = double.parse(amountController.text);
                    }
                  });

                  if (auth.getShiftType == 'G') {
                    if (!payments.calculateCash()) {
                      setState(() {
                        payment.amount = 0;
                      });
                      payments.calculateCash();
                      DialogBuilder(context).showSnackBar(t.cashOverFlowError);
                    }
                  }
                }
              },
              child: TextField(
                controller: amountController,
                decoration: InputDecoration(
                  icon: Icon(
                    getIcon(payment.icon),
                    color: themeData.primaryColor,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  hintText: t.egp,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                key: Key(payment.paymentName),
                enabled: payment.icon != 'CASH' || auth.getShiftType == 'F',
                onSubmitted: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      payment.amount = 0;
                    } else {
                      payment.amount = double.parse(value);
                    }
                  });

                  if (auth.getShiftType == 'G') {
                    if (!payments.calculateCash()) {
                      setState(() {
                        payment.amount = 0;
                      });
                      payments.calculateCash();
                      DialogBuilder(context).showSnackBar(t.cashOverFlowError);
                    }
                  }
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}
