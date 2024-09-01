import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:gas_track/core/network/open_vpn.dart';
import 'package:gas_track/core/view/splash_screen.dart';
import 'package:gas_track/core/view/ui/ui_constants.dart';
import 'package:gas_track/features/auth/controller/auth_provider.dart';
import 'package:gas_track/features/auth/view/auth_screen.dart';
import 'package:gas_track/features/home/controller/hanging_unit_provider.dart';
import 'package:gas_track/features/home/view/home_screen.dart';
import 'package:gas_track/features/payment/controller/payments_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/features/payment/view/payment_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final vpn = OpenVpnService();

    // check whether application is paused then disconnect vpn else re-connect
    if (state == AppLifecycleState.paused) {
      vpn.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      vpn.connect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // open vpn provier
        ChangeNotifierProvider(
          create: (context) => OpenVpnService(),
        ),
        // auth provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // hanging uints provider
        ChangeNotifierProvider(
          create: (_) => HangingUnitsProvider(),
        ),

        // payments provier [needs total sales and credit amount values]
        ChangeNotifierProxyProvider<HangingUnitsProvider, PaymentsProvider>(
          create: (context) => PaymentsProvider(
              context.hangingUnitsProviderWithNoListner.getTotalSales,
              context.hangingUnitsProviderWithNoListner.getCreditAmount),
          update: (_, value, previous) =>
              PaymentsProvider(value.getTotalSales, value.getCreditAmount),
        ),
      ],
      child: Consumer<OpenVpnService>(
        builder: (context, vpn, child) => Sizer(
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
              home: AnimatedSplashScreen.withScreenFunction(
                duration: 3000,
                splashIconSize: 75.w,
                splash: SplashScreen(stage: vpn.stage),
                splashTransition: SplashTransition.slideTransition,
                pageTransitionType: PageTransitionType.leftToRight,
                backgroundColor: Colors.white,
                screenFunction: () async {
                  // request notification permission
                  Permission.notification.isGranted.then((_) {
                    if (!_) Permission.notification.request();
                  });

                  // init vpn and connect
                  vpn.init();
                  vpn.connect();

                  Future.delayed(const Duration(seconds: 5));

                  return const AuthScreen();
                },
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
