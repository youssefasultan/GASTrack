import 'package:flutter/material.dart';
import 'package:gasolina/helpers/view/dash_separator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/auth.dart';
import '../../providers/payments.dart';
import '../../providers/products.dart';
import '../../providers/product.dart';

class DialogBuilder {
  DialogBuilder(this.context);

  final BuildContext context;

  void showLoadingIndicator(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              content: LoadingIndicator(text: text),
            ));
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }

  void showConfirmationDialog() {
    var t = AppLocalizations.of(context)!;

    final productsData = Provider.of<Products>(context, listen: false);
    final productsList = productsData.getProducts();
    final paymentData = Provider.of<Payments>(context, listen: false);

    final deviceSize = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: deviceSize.height * 0.8,
          width: deviceSize.width,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.confirm,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'Bebas',
                  ),
                ),
                const DashSeparator(),
                ConfirmationWarining(
                    context: context,
                    productsList: productsList,
                    t: t,
                    paymentData: paymentData),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _dialogTextButton(
                      () async {
                        Navigator.pop(context);
                        showLoadingIndicator(t.uploading);

                        try {
                          if (await paymentData.uploadShift(productsList)) {
                            hideOpenDialog();
                            showSuccessDialog(t.successMsg);
                          } else {
                            hideOpenDialog();
                            showErrorDialog(t.uploadError);
                          }
                        } catch (error) {
                          hideOpenDialog();
                          showErrorDialog(error.toString());
                        }
                      },
                      t.okay,
                      Colors.green,
                    ),
                    _dialogTextButton(
                      hideOpenDialog,
                      t.cancel,
                      Colors.red,
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog(
    String message,
  ) {
    var t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          t.error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        icon: const Icon(
          Icons.error_outline_sharp,
          color: Colors.red,
          size: 40.0,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          _dialogTextButton(
            hideOpenDialog,
            t.okay,
            Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }

  void showSuccessDialog(
    String message,
  ) {
    var t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          t.success,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        icon: const Icon(
          Icons.cloud_done_outlined,
          color: Colors.green,
          size: 40.0,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          _dialogTextButton(
            () {
              hideOpenDialog();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
              Provider.of<Auth>(context, listen: false).logout();

              // Navigator.of(context).pushNamedAndRemoveUntil(
              //     AuthScreen.routeName, (route) => false);
            },
            t.okay,
            Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }

  TextButton _dialogTextButton(Function()? fun, String title, Color color) {
    return TextButton(
      onPressed: fun,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 8.0,
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          color,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Bebas',
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ConfirmationWarining extends StatelessWidget {
  const ConfirmationWarining({
    super.key,
    required this.context,
    required this.productsList,
    required this.t,
    required this.paymentData,
  });

  final BuildContext context;
  final List<Product> productsList;
  final AppLocalizations t;
  final Payments paymentData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text(
                productsList[index].equipmentDesc,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                productsList[index].materialDesc,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${t.reading} : ${productsList[index].enteredReading.toString()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            itemCount: productsList.length,
          ),
        ),
        const DashSeparator(),
        SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.total,
                style: TextStyle(
                  fontFamily: 'Bebas',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                '${paymentData.getTotal()} ${t.egp}',
              ),
            ],
          ),
        )
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.text = ''});

  final String text;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _getLoadingIndicator(),
          _getHeading(context),
          _getText(displayedText, context)
        ],
      ),
    );
  }

  Padding _getLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }

  Widget _getHeading(context) {
    var t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        t.plesaeWait,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Text _getText(String displayedText, BuildContext context) {
    return Text(
      displayedText,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}
