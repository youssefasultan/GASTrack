import 'package:flutter/material.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';
import 'package:sizer/sizer.dart';


import 'dialog_widgets/confirmation_widget.dart';
import 'dialog_widgets/loading_indicator.dart';
import 'dialog_widgets/summery_widget.dart';
import '../ui/ui_constants.dart';

class DialogBuilder {
  DialogBuilder(this.context) {
    context = context;
  }

  BuildContext context;

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
    final paymentData = context.paymentsProviderWithNoListner;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SizedBox(
          height: 90.h,
          width: 100.w,
          child: Padding(
            padding: EdgeInsets.all(2.h),
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
                        showLoadingIndicator(context.translate.uploading);

                        try {
                          if (await paymentData.uploadShift(context)) {
                            hideOpenDialog();
                            if (context.mounted) {
                              showSuccessDialog(context.translate.successMsg);
                            }
                          } else {
                            hideOpenDialog();
                            if (context.mounted) {
                              showErrorDialog(context.translate.uploadError);
                            }
                          }
                        } catch (error) {
                          hideOpenDialog();
                          showErrorDialog(error.toString());
                        }
                      },
                      context.translate.confirm,
                      context.theme.primaryColor,
                      context.theme.primaryColor,
                    ),
                    _dialogTextButton(
                      hideOpenDialog,
                      context.translate.cancel,
                      Colors.white,
                      context.theme.primaryColor,
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
                context.authProvider.logout();
              },
              context.translate.confirm,
              context.theme.primaryColor,
              context.theme.primaryColor,
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
          context.translate.error,
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
            context.translate.okay,
            context.theme.primaryColor,
            context.theme.primaryColor,
          )
        ],
      ),
    );
  }

  void showSuccessDialog(
    String message,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.translate.success,
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
              showEndOfDaySummery();
            },
            context.translate.next,
            context.theme.primaryColor,
            context.theme.primaryColor,
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
          context.translate.deleteImg,
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
            context.translate.cancel,
            Colors.white,
            context.theme.primaryColor,
          ),
          _dialogTextButton(
            () {
              hideOpenDialog();
              if (isCash) {
                context.paymentsProviderWithNoListner.setCashRecipetImg('');
              } else {
                context.paymentsProviderWithNoListner
                    .removeImgPathFromList(path);
              }
            },
            context.translate.confirm,
            context.theme.primaryColor,
            context.theme.primaryColor,
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
    var textColorCheck = bgColor == context.theme.primaryColor;
    return TextButton(
      onPressed: fun,
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 8.0,
          ),
        ),
        backgroundColor: WidgetStateProperty.all(
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
