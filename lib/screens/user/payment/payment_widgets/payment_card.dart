import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

<<<<<<< HEAD:lib/screens/payment/payment_widgets/payment_card.dart
import '../../../helpers/view/ui_constants.dart';
import '../../../providers/payments_provider.dart';
=======
import '../../../../helpers/view/ui/ui_constants.dart';
import '../../../../providers/payments_provider.dart';
>>>>>>> 33ceacaadc489c1297489ee0afdef038ac9beab3:lib/screens/user/payment/payment_widgets/payment_card.dart

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
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        gradient: linerGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 5.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 60,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.total,
                  style: const TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${paymentData.getTotalCollection} ${t.egp}',
                  style: const TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 20,
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
