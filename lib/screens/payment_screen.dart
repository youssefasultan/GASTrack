import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/payments.dart';
import '../helpers/view/dialog_builder.dart';
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
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Payments>(context).fetchPayments().then((_) {
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
    var mediaQuery = MediaQuery.of(context).size;

    final paymentsData = Provider.of<Payments>(context);
    final paymentMethods = paymentsData.getPaymentsMethods();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.payment,
          style: TextStyle(
            fontFamily: 'Babas',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: mediaQuery.height * 0.3,
                  child: Center(
                    child: Image.asset(
                      'assets/images/pay.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          t.total,
                          style: TextStyle(
                            fontFamily: 'Bebas',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          '${paymentsData.getTotal()} ${t.egp}',
                          style: const TextStyle(
                            fontFamily: 'Bebas',
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
        onPressed: () => DialogBuilder(context).showConfirmationDialog(),
        child: Icon(
          Icons.upload,
          size: 35,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
