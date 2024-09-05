import 'package:flutter/material.dart';
import 'package:gas_track/core/data/shared_pref/shared.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:gas_track/core/view/ui/dialog_button.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'dialog_widgets/confirmation_widget.dart';
import 'dialog_widgets/loading_indicator.dart';
import 'dialog_widgets/summery_widget.dart';
import '../../constants/ui_constants.dart';

class DialogBuilder {
  DialogBuilder(this.context) {
    context = context;
  }

  BuildContext context;

  final shared = Shared();

  /// shows loading alert dialog
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
          ),
        );
      },
    );
  }

  /// show snackbar
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

  /// pop any dialog
  void hideOpenDialog() {
    Navigator.of(context).pop();
  }

  /// show end of day summery
  void showEndDayDialog() async {
    final sysDate = await shared.getSystemDate();
    final shiftDate = await shared.getShiftDate();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        elevation: 5,
        title: Text(
          context.translate.endDay,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.theme.primaryColor,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          DialogButton(
            fun: () {
              hideOpenDialog();
              showEndDayWarning(shiftDate);
            },
            title: context.translate.endDayStr,
            bgColor: context.theme.primaryColor,
            isEnabled: sysDate.isAfter(shiftDate),
          ),
          DialogButton(
            fun: () {
              hideOpenDialog();
              showConfirmationDialog(false);
            },
            title: context.translate.endShiftStr,
            bgColor: context.theme.primaryColor,
          ),
        ],
      ),
    );
  }

  /// show warining dalog that the day has ended
  void showEndDayWarning(DateTime shiftDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning,
          color: Colors.yellow,
          size: 10.h,
        ),
        content: Text(
          '${context.translate.endDayWarning} ${DateFormat('dd-MM-yyyy').format(shiftDate)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.theme.primaryColor,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          DialogButton(
            fun: () {
              hideOpenDialog();
              showConfirmationDialog(true);
            },
            title: context.translate.okay,
            bgColor: Colors.green,
            textColor: Colors.white,
          ),
          DialogButton(
            fun: () {
              hideOpenDialog();
            },
            title: context.translate.cancel,
            bgColor: Colors.red,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  /// if day has ended and user choose to end day a confrimation
  /// dialog is prsented
  void showConfirmationDialog(bool endDay) {
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
                ConfirmationWidget(endDay: endDay),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DialogButton(
                      fun: () async {
                        Navigator.pop(context);
                        showLoadingIndicator(context.translate.uploading);

                        try {
                          if (await paymentData.uploadShift(context, endDay)) {
                            hideOpenDialog();
                            showEndOfDaySummery();
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
                      title: context.translate.confirm,
                      bgColor: context.theme.primaryColor,
                    ),
                    DialogButton(
                      fun: hideOpenDialog,
                      title: context.translate.cancel,
                      bgColor: Colors.white,
                      borderColor: context.theme.primaryColor,
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

  /// show end of day summery
  Future<dynamic> showEndOfDaySummery() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SummeryWidget(),
              DialogButton(
                fun: () {
                  hideOpenDialog();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
                  context.authProvider.logout();
                },
                title: context.translate.confirm,
                bgColor: context.theme.primaryColor,
              )
            ],
          ),
        );
      },
    );
  }

  // show error dialog
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
          DialogButton(
            fun: hideOpenDialog,
            title: context.translate.okay,
            bgColor: context.theme.primaryColor,
          )
        ],
      ),
    );
  }

  /// show success dialog
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
          DialogButton(
            fun: () {
              hideOpenDialog();
              showEndOfDaySummery();
            },
            title: context.translate.next,
            bgColor: context.theme.primaryColor,
          )
        ],
      ),
    );
  }

  /// image deletion confrimation
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
          DialogButton(
            fun: hideOpenDialog,
            title: context.translate.cancel,
            bgColor: Colors.white,
            borderColor: context.theme.primaryColor,
          ),
          DialogButton(
            fun: () {
              hideOpenDialog();
              if (isCash) {
                context.paymentsProviderWithNoListner.setCashRecipetImg('');
              } else {
                context.paymentsProviderWithNoListner
                    .removeImgPathFromList(path);
              }
            },
            title: context.translate.confirm,
            bgColor: context.theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
