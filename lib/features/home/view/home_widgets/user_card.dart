import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/ui_constants.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 22.h,
      margin: EdgeInsets.all(1.h),
      padding: EdgeInsets.all(1.h),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        gradient: linerGradient,
      ),
      child: Container(
        margin: EdgeInsets.all(1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.translate.welcome},',
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                    color: context.theme.primaryColor,
                  ),
                ),
                Text(
                  context.authProvider.getName!,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  context.translate.station,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: context.theme.primaryColor,
                  ),
                ),
                Text(
                  context.authProvider.getLocationDesc!,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Container(
              height: 10.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.w,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(1.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.translate.shift,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      context.authProvider.getShiftNo!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
