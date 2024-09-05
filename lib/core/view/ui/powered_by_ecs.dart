import 'package:flutter/material.dart';
import 'package:gas_track/core/constants/ui_constants.dart';
import 'package:sizer/sizer.dart';

class PoweredByEcs extends StatelessWidget {
  const PoweredByEcs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Powered By ',
              style: TextStyle(
                color: blueColor,
                fontFamily: 'Bebas',
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/ecs_logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            )
          ],
        ),
      ),
    );
  }
}
