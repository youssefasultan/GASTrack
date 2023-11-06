import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/payments.dart';
import '../helpers/view/dialog_builder.dart';
import '../widgets/payment_card.dart';
import '../widgets/payment_list_tile.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var _isLoading = false;
  var _isInit = true;

  @override
  void didChangeDependencies() {
    final auth = Provider.of<Auth>(context, listen: false);

    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Payments>(context).fetchPayments(auth.getShiftType).then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        DialogBuilder(context).showErrorDialog(error.toString());
      });
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);

    final paymentsData = Provider.of<Payments>(context);
    final paymentMethods = paymentsData.getPaymentsMethods;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.payment,
          style: TextStyle(
            fontFamily: 'Babas',
            fontWeight: FontWeight.bold,
            color: themeData.primaryColor,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: themeData.primaryColor,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
                Provider.of<Auth>(context, listen: false).logout();
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
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const PaymentCard(),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) =>
                        ChangeNotifierProvider.value(
                      value: paymentMethods[index],
                      child: const PaymentTile(),
                    ),
                    itemCount: paymentMethods.length,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (paymentsData.validatePayments()) {
            DialogBuilder(context).showErrorDialog(t.totalError);
          } else {
            DialogBuilder(context).showConfirmationDialog();
          }
        },
        child: Icon(
          Icons.upload,
          size: 35,
          color: themeData.primaryColor,
        ),
      ),
    );
  }
}
