import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/helpers/view/ui/ui_constants.dart';

import 'auth_widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
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
          const AuthCard(),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Copyright \u00A9 2024 ECS. All rights reserved. V0.1.0.17',
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
