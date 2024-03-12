import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/helpers/data/data_constants.dart';
import 'package:gas_track/helpers/view/ui/ui_constants.dart';
import 'package:sizer/sizer.dart';

import 'auth_widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var t = AppLocalizations.of(context)!;

    return Scaffold(
      // resizeToAvoidBottomInset: true,
      body: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          // add logo
          SizedBox(
            width: 100.w,
            height: 20.h,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(
            width: 100.w,
            height: 20.h,
            child: Padding(
              padding: EdgeInsets.only(
                left: 5.w,
              ),
              child: Text(
                t.appTitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bebas',
                  color: themeData.primaryColor,
                ),
              ),
            ),
          ),
          const AuthCard(),
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Copyright \u00A9 2024 ECS. All rights reserved. V$vNo',
              style: TextStyle(
                color: blueColor,
                fontFamily: 'Bebas',
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
