import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:gas_track/core/view/ui/powered_by_ecs.dart';
import 'package:gas_track/core/view/ui/ui_constants.dart';
import 'package:gas_track/features/auth/controller/auth_provider.dart';
import 'package:gas_track/features/auth/view/auth_screen.dart';
import 'package:gas_track/features/home/controller/hanging_unit_provider.dart';
import 'package:gas_track/features/home/view/home_screen.dart';
import 'package:gas_track/features/payment/controller/payments_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/features/payment/view/payment_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HangingUnitsProvider(),
        ),
        ChangeNotifierProxyProvider<HangingUnitsProvider, PaymentsProvider>(
          create: (context) => PaymentsProvider(
              context.hangingUnitsProviderWithNoListner.getTotalSales,
              context.hangingUnitsProviderWithNoListner.getCreditAmount),
          update: (_, value, previous) =>
              PaymentsProvider(value.getTotalSales, value.getCreditAmount),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) => Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              onGenerateTitle: (context) {
                return context.translate.appTitle;
              },
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('ar', ''),
              ],
              theme: ThemeData(
                fontFamily: 'Babas',
                useMaterial3: true,
                colorScheme:
                    ColorScheme.fromSeed(seedColor: blueColor).copyWith(
                  primary: blueColor,
                  secondary: redColor,
                ),
              ),
              home: AnimatedSplashScreen(
                duration: 3000,
                splashIconSize: 75.w,
                splash: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                        ),
                      ),
                      const PoweredByEcs(),
                    ],
                  ),
                ),
                nextScreen: const AuthScreen(),
                splashTransition: SplashTransition.slideTransition,
                pageTransitionType: PageTransitionType.leftToRight,
                backgroundColor: Colors.white,
              ),
              routes: {
                HomeScreen.routeName: (context) => const HomeScreen(),
                PaymentScreen.routeName: (context) => const PaymentScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
