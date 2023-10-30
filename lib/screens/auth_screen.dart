import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var t = AppLocalizations.of(context)!;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bebas',
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Flexible(
            flex: deviceSize.width > 600 ? 2 : 1,
            child: const AuthCard(),
          ),
        ],
      ),
    );
  }
}
