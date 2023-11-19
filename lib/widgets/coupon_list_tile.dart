import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/payment.dart';
import '../providers/payments_provider.dart';

class CouponListTile extends StatefulWidget {
  const CouponListTile({super.key});

  @override
  State<CouponListTile> createState() => _CouponListTileState();
}

class _CouponListTileState extends State<CouponListTile> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final coupon = Provider.of<CouponData>(context);
    final payments = Provider.of<PaymentsProvider>(context, listen: false);

    TextEditingController couponCountController =
        TextEditingController(text: coupon.count.toString());
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
              fontSize: 18,
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Focus(
              onFocusChange: (value) {
                if (!value) {
                  setState(() {
                    coupon.count = int.parse(couponCountController.text);
                    coupon.amount = coupon.value * coupon.count;
                  });
                  payments.calculateCouponTotal();
                } else if (coupon.count == 0) {
                  couponCountController.clear();
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    coupon.count = int.parse(value);
                    coupon.amount = coupon.value * coupon.count;
                  });
                  payments.calculateCouponTotal();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
