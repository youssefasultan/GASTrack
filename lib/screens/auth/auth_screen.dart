import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/helpers/view/ui/ui_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'auth_widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  String get getVersionNumber {
    String version = '';
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
    });

    return version;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);

    var t = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // add logo
          SizedBox(
            width: double.infinity,
            height: deviceSize.height * 0.3,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
      
          SizedBox(
            width: double.infinity,
            height: deviceSize.height * 0.2,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 25,
              ),
              child: Text(
                t.appTitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bebas',
                  color: themeData.primaryColor,
                ),
              ),
            ),
          ),
          Flexible(
            flex: deviceSize.width > 600 ? 2 : 1,
            child: const AuthCard(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text(
              'Copyright \u00A9 2024 ECS. All rights reserved. V$getVersionNumber',
              style: TextStyle(
                color: blueColor,
                fontFamily: 'Bebas',
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
