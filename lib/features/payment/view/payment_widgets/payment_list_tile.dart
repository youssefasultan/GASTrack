import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../model/payment.dart';
import 'coupon_list_tile.dart';

class PaymentTile extends StatefulWidget {
  const PaymentTile({super.key});

  @override
  State<PaymentTile> createState() => _PaymentTileState();
}

class _PaymentTileState extends State<PaymentTile> {
  late TextEditingController amountController;
  late FocusNode amountFN;

  @override
  void initState() {
    amountFN = FocusNode();
    amountController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFN.dispose();
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
    final payment = context.getPayment;
    amountController.text =
        payment.amount == 0 ? '' : payment.amount.toString();

    if (context.authProvider.getShiftType == 'G' && payment is Coupon) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        child: ExpansionTile(
          key: Key(payment.paymentType),
          title: Text(
            payment.paymentName,
            style: TextStyle(
              fontFamily: 'Bebas',
              color: context.theme.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: context.theme.primaryColorLight,
          collapsedBackgroundColor: context.theme.primaryColorLight,
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
              color: context.theme.primaryColor,
              fontSize: 12.sp,
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

                  if (!context.paymentsProviderWithNoListner.calculateCash()) {
                    setState(() {
                      payment.amount = 0;
                    });
                    context.paymentsProviderWithNoListner.calculateCash();
                    context.dialogBuilder
                        .showSnackBar(context.translate.cashOverFlowError);
                  }
                }
              },
              child: TextField(
                focusNode: amountFN,
                controller: amountController,
                decoration: InputDecoration(
                  icon: Icon(
                    getIcon(payment.icon),
                    color: context.theme.primaryColor,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  hintText: context.translate.egp,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                key: Key(payment.paymentName),
                enabled: payment.icon != 'CASH',
                onTapOutside: (event) {
                  amountFN.unfocus();
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}
