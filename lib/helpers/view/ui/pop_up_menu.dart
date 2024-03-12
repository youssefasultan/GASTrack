import 'package:flutter/material.dart';
import 'package:gas_track/providers/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SettingsPopUpMenu extends StatelessWidget {
  const SettingsPopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var t = AppLocalizations.of(context)!;
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: themeData.primaryColor,
      ),
      onSelected: (value) {
        if (value == 'logout') {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
          Provider.of<AuthProvider>(context, listen: false).logout();
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
                t.logout,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: themeData.primaryColor,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
