import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/widgets/coupon_list_tile.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/payment.dart';
import '../providers/payments.dart';

class PaymentTile extends StatefulWidget {
  const PaymentTile({super.key});

  @override
  State<PaymentTile> createState() => _PaymentTileState();
}

class _PaymentTileState extends State<PaymentTile> {
  late AppLocalizations t;

  String getTitle(String paymentType) {
    switch (paymentType) {
      case 'COUPON':
        return t.coupon;
      case 'VISA':
        return t.card;
      case 'CASH':
        return t.cash;
      default:
        return '';
    }
  }

  IconData? getIcon(String paymentType) {
    switch (paymentType) {
      case 'COUPON':
        return Icons.card_membership;
      case 'VISA':
        return Icons.payment;
      case 'CASH':
        return Icons.monetization_on_sharp;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);

    final payment = Provider.of<Payment>(context);
    final payments = Provider.of<Payments>(context);
    final auth = Provider.of<Auth>(context, listen: false);

    TextEditingController amountController =
        TextEditingController(text: payment.amount.toString());

    if (auth.getShiftType == 'G' && payment is Coupon) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: ExpansionTile(
          key: Key(payment.paymentType),
          title: Text(
            t.coupon,
            style: TextStyle(
              fontFamily: 'Bebas',
              color: Theme.of(context).primaryColor,
              fontSize: 16,
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: ListTile(
          key: Key(payment.paymentType),
          title: Text(
            getTitle(payment.icon),
            style: TextStyle(
              fontFamily: 'Bebas',
              color: themeData.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Focus(
              onFocusChange: (value) {
                if (value &&
                    amountController.text.isNotEmpty &&
                    double.parse(amountController.text) == 0.0) {
                  amountController.clear();
                } else if (!value) {
                  setState(() {
                    payment.amount = double.parse(amountController.text);
                  });

                  payments.calculateCash();
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
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                key: Key(payment.icon),
                enabled: payment.icon != 'CASH',
                onSubmitted: (value) {
                  setState(() {
                    payment.amount = double.parse(value);
                  });
                  payments.calculateCash();
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}
