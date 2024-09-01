import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';

import 'package:sizer/sizer.dart';

class SettingsPopUpMenu extends StatelessWidget {
  const SettingsPopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: context.theme.primaryColor,
      ),
      onSelected: (value) {
        if (value == 'logout') {
          // logout
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
          context.authProvider.logout();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red,
                size: 3.h,
              ),
              SizedBox(width: 2.w),
              Text(
                context.translate.logout,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: context.theme.primaryColor,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
