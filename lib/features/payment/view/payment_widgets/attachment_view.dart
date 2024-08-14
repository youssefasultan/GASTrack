import 'package:flutter/material.dart';
import 'package:gas_track/features/payment/view/payment_widgets/cash_recipet_img.dart';
import 'package:gas_track/features/payment/view/payment_widgets/visa_recipet_imgs.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:sizer/sizer.dart';

class AttachmentView extends StatelessWidget {
  const AttachmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, top: 2.h, right: 2.h),
          child: Text(
            context.translate.addCashPic,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: context.theme.primaryColor,
            ),
          ),
        ),
        const CashRecipetImg(),
        Padding(
          padding: EdgeInsets.only(left: 2.w, top: 2.h, right: 2.h),
          child: Text(
            context.translate.addVisaPics,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: context.theme.primaryColor,
            ),
          ),
        ),
        const VisaRecieptsImgs(),
      ],
    );
  }
}
