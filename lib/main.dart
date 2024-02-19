import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'helpers/view/ui/ui_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/hanging_unit_provider.dart';
import 'providers/payments_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/payment/payment_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MainApp());
}

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
              Provider.of<HangingUnitsProvider>(context, listen: false)
                  .getTotalSales),
          update: (context, value, previous) =>
              PaymentsProvider(value.getTotalSales),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) => MaterialApp(
          onGenerateTitle: (context) {
            return AppLocalizations.of(context)!.appTitle;
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
            colorScheme: ColorScheme.fromSeed(seedColor: blueColor).copyWith(
              primary: blueColor,
              secondary: redColor,
            ),
          ),
          home: auth.isAuth ? const HomeScreen() : const AuthScreen(),
          routes: {
            HomeScreen.routeName: (context) => const HomeScreen(),
            PaymentScreen.routeName: (context) => const PaymentScreen(),
          },
        ),
      ),
    );
  }
}
