import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:gas_track/core/view/ui/powered_by_ecs.dart';
import 'package:sizer/sizer.dart';

import 'auth_widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Text(
                context.translate.appTitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bebas',
                  color: context.theme.primaryColor,
                ),
              ),
            ),
          ),
          const AuthCard(),
          const PoweredByEcs()
        ],
      ),
    );
  }
}
