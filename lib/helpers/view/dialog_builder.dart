import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/payments_provider.dart';
import '../../providers/hanging_unit_provider.dart';
import '../data/constants.dart';
import 'dash_separator.dart';

class DialogBuilder {
  DialogBuilder(this.context) {
    t = AppLocalizations.of(context)!;
  }

  final BuildContext context;
  late AppLocalizations t;

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

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: redColor,
      ),
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }

  void showConfirmationDialog() {
    final paymentData = Provider.of<PaymentsProvider>(context, listen: false);

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
                Row(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showEndOfDaySummery() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SummeryWidget(),
            _dialogTextButton(
              () {
                hideOpenDialog();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
              t.confirm,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
            )
          ],
        );
      },
    );
  }

  void showErrorDialog(
    String message,
  ) {
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
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;

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
          isAdmin
              ? _dialogTextButton(
                  () {
                    hideOpenDialog();
                    showEndOfDaySummery();
                  },
                  t.next,
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor,
                )
              : _dialogTextButton(
                  () {
                    hideOpenDialog();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
                    Provider.of<AuthProvider>(context, listen: false).logout();
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

class SummeryWidget extends StatefulWidget {
  const SummeryWidget({
    super.key,
  });

  @override
  State<SummeryWidget> createState() => _SummeryWidgetState();
}

class _SummeryWidgetState extends State<SummeryWidget> {
  var _isLoading = false;
  var _isInit = true;
  late AppLocalizations t;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<PaymentsProvider>(context)
          .getEndOfDaySummeryPayments()
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

  String getTitle(String paymentType) {
    switch (paymentType) {
      case 'Coupon':
        return t.coupon;
      case 'Visa':
        return t.card;
      case 'Cash':
        return t.cash;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    t = AppLocalizations.of(context)!;

    final summeryData = Provider.of<PaymentsProvider>(context, listen: false);
    final summeryItems = summeryData.getSummery;
    final summryTotal = summeryData.calculateTotalSummery();

    return SizedBox(
      height: deviceSize.height * 0.7,
      width: deviceSize.width,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text(
                    t.daySummery,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Bebas',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const DashSeparator(),
                Expanded(
                  child: ListView(
                    children: [
                      DataTable(
                        columns: [
                          DataColumn(label: Text(t.shift)),
                          DataColumn(label: Text(t.payment)),
                          DataColumn(label: Text(t.amount))
                        ],
                        rows: summeryItems
                            .map((e) => DataRow(
                                  cells: [
                                    DataCell(Text(e.shift)),
                                    DataCell(Text(getTitle(e.paymentType))),
                                    DataCell(Text(e.value.toString())),
                                  ],
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const DashSeparator(),
                Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${t.total} ${getTitle(summryTotal.keys.elementAt(index))}',
                              style: TextStyle(
                                fontFamily: 'Bebas',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              '${summryTotal.values.elementAt(index)} ${t.egp}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: summryTotal.length,
                  ),
                ),
              ],
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

    final shiftType =
        Provider.of<AuthProvider>(context, listen: false).getShiftType;
    final hangingUnitsData =
        Provider.of<HangingUnitsProvider>(context, listen: false);
    final productsList = hangingUnitsData.getHoseList;
    final tankList = hangingUnitsData.getTanks;
    final paymentData = Provider.of<PaymentsProvider>(context, listen: false);

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
                productsList[index].measuringPointDesc,
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
