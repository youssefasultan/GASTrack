import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/auth.dart';
import '../../providers/payments.dart';
import '../../providers/products.dart';
import 'dash_separator.dart';

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

    final paymentData = Provider.of<Payments>(context, listen: false);

    final authData = Provider.of<Auth>(context, listen: false);

    final deviceSize = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SizedBox(
          height: deviceSize.height * 0.9,
          width: deviceSize.width,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t.confirm} ?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'Bebas',
                  ),
                ),
                const DashSeparator(),
                const ConfirmationWarining(),
                !authData.isAdmin
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _dialogTextButton(
                            () async {
                              Navigator.pop(context);
                              showLoadingIndicator(t.uploading);

                              try {
                                if (await paymentData.uploadShift(context)) {
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
                            t.confirm,
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor,
                          ),
                          _dialogTextButton(
                            hideOpenDialog,
                            t.cancel,
                            Colors.white,
                            Theme.of(context).primaryColor,
                          )
                        ],
                      )
                    : _dialogTextButton(
                        () {
                          hideOpenDialog();
                          showEndOfDaySummery();
                        },
                        t.next,
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor,
                      )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showEndOfDaySummery() {
    final deviceSize = MediaQuery.of(context).size;
    var t = AppLocalizations.of(context)!;
    final endOfDayData = Provider.of<Payments>(context, listen: false)
        .getEndOfDaySummeryPayments();

    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: deviceSize.height * 0.8,
          width: deviceSize.width,
          child: Column(
            children: [
              Text(
                t.daySummery,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Bebas',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const DashSeparator(),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => const ListTile(),
                  itemCount: 3,
                ),
              ),
              const DashSeparator(),
              Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.1,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                      '${endOfDayData['collection']} ${t.egp}',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            },
            t.okay,
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }

  TextButton _dialogTextButton(
      Function()? fun, String title, Color bgColor, Color borderColor) {
    var textColorCheck = bgColor == Theme.of(context).primaryColor;
    return TextButton(
      onPressed: fun,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor,
              width: 1,
            ),
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
          bgColor,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Bebas',
          fontSize: 20.0,
          color: textColorCheck ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class ConfirmationWarining extends StatelessWidget {
  const ConfirmationWarining({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    final shiftType = Provider.of<Auth>(context, listen: false).getShiftType;
    final productsData = Provider.of<Products>(context, listen: false);
    final productsList = productsData.getProducts;
    final tankList = productsData.getTanks;
    final paymentData = Provider.of<Payments>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            t.dispenser,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(
          width: double.maxFinite,
          height: shiftType == 'F' ? size.height * 0.3 : size.height * 0.5,
          child: ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text(
                productsList[index].equipmentDesc,
                style: const TextStyle(
                  fontSize: 15,
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
                    '${t.quantity} : ${productsList[index].enteredReading.toString()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${t.amount} : ${productsList[index].enteredAmount.toString()}',
                    style: const TextStyle(
                      fontSize: 14,
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
        if (shiftType == 'F' && tankList.isNotEmpty) ...{
          const DashSeparator(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(
              t.tank,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            width: double.maxFinite,
            height: size.height * 0.2,
            child: ListView.builder(
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  tankList[index].material,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Bebas',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${t.amount} : ${tankList[index].quantity.toString()}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${t.reading} : ${tankList[index].expectedQuantity.toString()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bebas',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              itemCount: tankList.length,
            ),
          )
        },
        const DashSeparator(),
        Container(
          width: double.maxFinite,
          height: size.height * 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                '${paymentData.getTotalCollection} ${t.egp}',
                style: const TextStyle(
                  fontSize: 18,
                ),
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
