import 'package:flutter/material.dart';
import 'package:gas_track/features/auth/controller/auth_provider.dart';
import 'package:gas_track/features/home/controller/hanging_unit_provider.dart';
import 'package:gas_track/features/home/model/hanging_unit.dart';
import 'package:gas_track/features/home/model/hose.dart';
import 'package:gas_track/features/home/model/tank.dart';
import 'package:gas_track/features/payment/controller/payments_provider.dart';
import 'package:gas_track/features/payment/model/payment.dart';

import 'package:gas_track/helpers/view/dialog/dialog_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

extension BuildContextEntension<T> on BuildContext {
  DialogBuilder get dialogBuilder => DialogBuilder(this);

  AppLocalizations get translate => AppLocalizations.of(this)!;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  ThemeData get theme => Theme.of(this);

  HangingUnitsProvider get hangingUnitsProvider =>
      Provider.of<HangingUnitsProvider>(this);
  HangingUnitsProvider get hangingUnitsProviderWithNoListner =>
      Provider.of<HangingUnitsProvider>(this, listen: false);

  AuthProvider get authProvider =>
      Provider.of<AuthProvider>(this, listen: false);

  PaymentsProvider get paymentsProvider => read<PaymentsProvider>();
  PaymentsProvider get paymentsProviderWithNoListner =>
      Provider.of<PaymentsProvider>(this, listen: false);

  CouponData get getCoupon => Provider.of<CouponData>(this);
  Payment get getPayment => watch<Payment>();
  HangingUnit get getHangingUnit => Provider.of<HangingUnit>(this);
  Hose get getHose => Provider.of<Hose>(this);
  Tank get getTank => Provider.of<Tank>(this);
}
