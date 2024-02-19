import 'package:flutter/material.dart';
import 'package:gas_track/providers/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

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
                color: themeData.primaryColor,
                size: 30.0,
              ),
              Text(
                t.logout,
                style: TextStyle(
                  fontSize: 18,
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
