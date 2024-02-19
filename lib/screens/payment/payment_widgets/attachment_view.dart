import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/screens/payment/payment_widgets/cash_recipet_img.dart';
import 'package:gas_track/screens/payment/payment_widgets/visa_recipet_imgs.dart';

class AttachmentView extends StatelessWidget {
  const AttachmentView({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: Text(
            t.addCashPic,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: themeData.primaryColor,
            ),
          ),
        ),
        const CashRecipetImg(),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: Text(
            t.addVisaPics,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: themeData.primaryColor,
            ),
          ),
        ),
        const VisaRecieptsImgs(),
      ],
    );
  }
}
