import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'helpers/data/constants.dart';
import './screens/home_screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import 'providers/payments.dart';
import 'providers/products.dart';
import 'screens/payment_screen.dart';

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

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => Products(),
        ),
        ChangeNotifierProxyProvider<Products, Payments>(
          create: (context) => Payments(
              Provider.of<Products>(context, listen: false).getTotalSales),
          update: (context, value, previous) => Payments(value.getTotalSales),
        ),
      ],
      child: Consumer<Auth>(
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
