import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_track/helpers/view/dialog/dialog_builder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/payment.dart';
import '../../../providers/payments_provider.dart';

class CouponListTile extends StatefulWidget {
  const CouponListTile({super.key});

  @override
  State<CouponListTile> createState() => _CouponListTileState();
}

class _CouponListTileState extends State<CouponListTile> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var t = AppLocalizations.of(context)!;

    final coupon = Provider.of<CouponData>(context);
    final payments = Provider.of<PaymentsProvider>(context, listen: false);

    TextEditingController couponCountController = TextEditingController(
        text: coupon.count == 0 ? '' : coupon.count.toString());

    TextEditingController couponValueController = TextEditingController(
        text: coupon.value == 0 ? '' : coupon.value.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            coupon.coupon,
            style: TextStyle(
              color: themeData.primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            coupon.amount.toString(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 15,
            ),
          ),
          if (coupon.businessPartner.isNotEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Focus(
                onFocusChange: (value) {
                  if (!value) {
                    setState(() {
                      if (couponValueController.text.isNotEmpty) {
                        coupon.value = double.parse(couponValueController.text);
                        coupon.amount = coupon.value * coupon.count;
                      } else {
                        coupon.value = 0;
                      }
                    });

                    if (!payments.calculateCouponTotal()) {
                      setState(() {
                        coupon.amount = 0;
                        coupon.count = 0;
                      });
                      payments.calculateCouponTotal();
                      DialogBuilder(context).showSnackBar(t.cashOverFlowError);
                    }
                  }
                },
                child: TextField(
                  key: Key(coupon.coupon),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    hintText: t.value,
                  ),
                  controller: couponValueController,
                  onSubmitted: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        coupon.value = double.parse(couponValueController.text);
                        coupon.amount = coupon.value * coupon.count;
                      } else {
                        coupon.value = 0;
                      }
                    });

                    if (!payments.calculateCouponTotal()) {
                      setState(() {
                        coupon.amount = 0;
                        coupon.count = 0;
                      });
                      payments.calculateCouponTotal();
                      DialogBuilder(context).showSnackBar(t.cashOverFlowError);
                    }
                  },
                ),
              ),
            ),
          SizedBox(
            width: coupon.businessPartner.isNotEmpty
                ? MediaQuery.of(context).size.width * 0.25
                : MediaQuery.of(context).size.width * 0.3,
            child: Focus(
              onFocusChange: (value) {
                if (!value) {
                  if (coupon.businessPartner.isNotEmpty && coupon.value == 0) {
                    DialogBuilder(context).showSnackBar(t.couponValueError);
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
                      DialogBuilder(context).showSnackBar(t.cashOverFlowError);
                    }
                  }
                }
              },
              child: TextField(
                key: Key(coupon.coupon),
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
                  hintText: t.count,
                ),
                onSubmitted: (value) {
                  if (coupon.businessPartner.isNotEmpty && coupon.value == 0) {
                    DialogBuilder(context).showSnackBar(t.couponValueError);
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
                      DialogBuilder(context).showSnackBar(t.cashOverFlowError);
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
