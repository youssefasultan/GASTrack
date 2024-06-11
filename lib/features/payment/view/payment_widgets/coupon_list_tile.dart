import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';
import 'package:sizer/sizer.dart';



class CouponListTile extends StatefulWidget {
  const CouponListTile({super.key});

  @override
  State<CouponListTile> createState() => _CouponListTileState();
}

class _CouponListTileState extends State<CouponListTile> {
  final countFN = FocusNode();
  late TextEditingController couponCountController;

  @override
  void initState() {
    couponCountController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    couponCountController.dispose();
    countFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
   
    final coupon = context.getCoupon;
    final payments = context.paymentsProviderWithNoListner;

    couponCountController.text =
        coupon.count == 0 ? '' : coupon.count.toString();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            coupon.coupon,
            style: TextStyle(
              color: context.theme.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            coupon.amount.toString(),
            style: TextStyle(
              color: context.theme.primaryColor,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(
            width: 40.w,
            child: Focus(
              onFocusChange: (value) {
                if (!value) {
                  if (coupon.businessPartner.isNotEmpty && coupon.value == 0) {
                    context.dialogBuilder.showSnackBar(context.translate.couponValueError);
                  } else {
                    final count = couponCountController.text.isEmpty
                        ? 0
                        : int.parse(couponCountController.text);
                    setState(() {
                      coupon.count = count;
                      coupon.amount = coupon.value * coupon.count;
                    });

                    if (!payments.calculateCouponTotal()) {
                      setState(() {
                        coupon.amount = 0;
                        coupon.count = 0;
                      });
                      payments.calculateCouponTotal();
                      context.dialogBuilder.showSnackBar(context.translate.cashOverFlowError);
                    }
                  }
                }
              },
              child: TextField(
                key: const Key('count'),
                focusNode: countFN,
                controller: couponCountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  // for version 2 and greater youcan also use this
                  FilteringTextInputFormatter.digitsOnly
                ],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  hintText: context.translate.count,
                ),
                onTapOutside: (event) {
                  countFN.unfocus();
                },
                onSubmitted: (value) {
                  if (coupon.businessPartner.isNotEmpty && coupon.value == 0) {
                    context.dialogBuilder.showSnackBar(context.translate.couponValueError);
                  } else {
                    final count = value.isEmpty ? 0 : int.parse(value);
                    setState(() {
                      coupon.count = count;
                      coupon.amount = coupon.value * coupon.count;
                    });
                    if (!payments.calculateCouponTotal()) {
                      setState(() {
                        coupon.amount = 0;
                        coupon.count = 0;
                      });
                      payments.calculateCouponTotal();
                      context.dialogBuilder.showSnackBar(context.translate.cashOverFlowError);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
