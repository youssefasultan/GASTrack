import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../helpers/view/ui/ui_constants.dart';
import '../../../providers/auth_provider.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<AuthProvider>(context, listen: false);
    var t = AppLocalizations.of(context)!;
    // ThemeData themeData = Theme.of(context);

    return Container(
      width: 100.w,
      height: 20.h,
      margin: EdgeInsets.all(2.h),
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
                  '${t.welcome},',
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  userSettings.getName!,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  t.station,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  userSettings.getLocationDesc!,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                      t.shift,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      userSettings.getShiftNo!,
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
