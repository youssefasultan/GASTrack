import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:gas_track/helpers/view/ui/pop_up_menu.dart';
import 'package:gas_track/providers/auth_provider.dart';
import 'package:gas_track/screens/payment/payment_widgets/payment_tabbar_library.dart';
import 'package:sizer/sizer.dart';

import '../../helpers/view/dialog/dialog_builder.dart';
import '../../providers/payments_provider.dart';
import 'payment_widgets/payment_card.dart';
import 'payment_widgets/payment_list_tile.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  var _isLoading = false;
  var _isInit = true;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<PaymentsProvider>(context)
          .fetchPayments(auth.getShiftType)
          .then((_) {
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

    final paymentsData = Provider.of<PaymentsProvider>(context);
    final paymentMethods = paymentsData.getPaymentsMethods;
    final auth = Provider.of<AuthProvider>(context, listen: false);

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
        actions: const [
          SettingsPopUpMenu(),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const PaymentCard(),
                if (auth.getShiftType == 'F')
                  Expanded(
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(
                              text: t.payment,
                            ),
                            Tab(
                              text: t.attachment,
                            ),
                          ],
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                        ),
                        PaymentTabBarLibrary(
                          tabController: _tabController,
                          paymentMethods: paymentMethods,
                        ),
                      ],
                    ),
                  )
                else
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
      floatingActionButton: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
        child: FloatingActionButton(
          onPressed: () {
            if (paymentsData.validatePayments()) {
              DialogBuilder(context).showErrorDialog(t.totalError);
            } else {
              DialogBuilder(context).showConfirmationDialog();
            }
          },
          child: Icon(
            Icons.upload,
            size: 5.h,
            color: themeData.primaryColor,
          ),
        ),
      ),
    );
  }
}
