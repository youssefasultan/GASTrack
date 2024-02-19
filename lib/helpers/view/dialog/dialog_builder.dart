import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/payments_provider.dart';

import 'dialog_widgets/confirmation_widget.dart';
import 'dialog_widgets/loading_indicator.dart';
import 'dialog_widgets/summery_widget.dart';
import '../ui/ui_constants.dart';

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
        return PopScope(
            onPopInvoked: (didPop) => false,
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(10.0),
        duration: const Duration(seconds: 2),
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
                const ConfirmationWidget(),
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

  void showDeleteImgConfrimation(bool isCash, String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          t.deleteImg,
          textAlign: TextAlign.center,
        ),
        icon: const Icon(
          Icons.delete,
          size: 20,
        ),
        iconColor: redColor,
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          _dialogTextButton(
            hideOpenDialog,
            t.cancel,
            Colors.white,
            Theme.of(context).primaryColor,
          ),
          _dialogTextButton(
            () {
              hideOpenDialog();
              if (isCash) {
                Provider.of<PaymentsProvider>(context, listen: false)
                    .setCashRecipetImg('');
              } else {
                Provider.of<PaymentsProvider>(context, listen: false)
                    .removeImgPathFromList(path);
              }
            },
            t.confirm,
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Future<DateTime?> showDatePickerDialog() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
