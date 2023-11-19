import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/view/dialog_builder.dart';
import '../models/hose.dart';
import '../providers/auth_provider.dart';

class HoseListTile extends StatelessWidget {
  const HoseListTile({super.key});

  String getUom(String mesruementUnit, AppLocalizations t) {
    switch (mesruementUnit) {
      case 'L':
        return t.liter;

      case 'M3':
        return t.m3;
      default:
        return '';
    }
  }

  bool amountValidation(Hose hose, double amount, double reading) {
    return (amount - hose.lastAmount) !=
        ((reading - hose.lastReading) * hose.unitPrice);
  }

  @override
  Widget build(BuildContext context) {
    final hose = Provider.of<Hose>(context);
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;
    AppLocalizations t = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);

    TextEditingController lastReadingController =
        TextEditingController(text: hose.lastReading.toString());

    TextEditingController readingController = TextEditingController(
        text: hose.enteredReading == 0.0 ? '' : hose.enteredReading.toString());

    TextEditingController lastAmountController =
        TextEditingController(text: hose.lastAmount.toString());

    TextEditingController amountController = TextEditingController(
        text: hose.enteredAmount == 0.0 ? '' : hose.enteredAmount.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: ExpansionTile(
        key: UniqueKey(),
        title: Text(
          hose.measuringPointDesc,
          style: TextStyle(
            fontFamily: 'Bebas',
            color: themeData.primaryColor,
          ),
        ),
        subtitle: Text(hose.materialDesc),
        collapsedBackgroundColor: themeData.primaryColorLight,
        backgroundColor: Colors.white,
        expandedAlignment: Alignment.center,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 75,
                  child: Text(
                    t.reading,
                    style: TextStyle(
                      fontFamily: 'Bebas',
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (value) {
                      if (!value) {
                        hose.lastReading =
                            double.parse(lastReadingController.text);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintText: getUom(hose.measuringUnit, t),
                        ),
                        textAlign: TextAlign.center,
                        controller: lastReadingController,
                        keyboardType: TextInputType.number,
                        key: UniqueKey(),
                        enabled: isAdmin,
                        onSubmitted: (value) {
                          hose.lastReading = double.parse(value);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (value) {
                      if (!value &&
                          readingController.text.isNotEmpty &&
                          double.parse(readingController.text) <
                              hose.lastReading) {
                        DialogBuilder(context).showSnackBar(t.readingError);
                        readingController.clear();
                      } else if (!value) {
                        hose.enteredReading =
                            double.parse(readingController.text);
                        hose.quantity = hose.enteredReading - hose.lastReading;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintText: getUom(hose.measuringUnit, t),
                        ),
                        textAlign: TextAlign.center,
                        controller: readingController,
                        keyboardType: TextInputType.number,
                        key: UniqueKey(),
                        onSubmitted: (value) {
                          if (double.parse(value) < hose.lastReading) {
                            DialogBuilder(context).showSnackBar(t.readingError);
                            readingController.clear();
                          } else {
                            hose.enteredReading = double.parse(value);
                            hose.quantity =
                                hose.enteredReading - hose.lastReading;
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 75,
                  child: Text(
                    t.amount,
                    style: TextStyle(
                      fontFamily: 'Bebas',
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (value) {
                      if (!value) {
                        hose.lastAmount =
                            double.parse(lastAmountController.text);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintText: getUom(hose.measuringUnit, t),
                        ),
                        textAlign: TextAlign.center,
                        controller: lastAmountController,
                        keyboardType: TextInputType.number,
                        key: UniqueKey(),
                        enabled: isAdmin,
                        onSubmitted: (value) {
                          hose.lastAmount = double.parse(value);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (value) {
                      if (!value &&
                          double.parse(amountController.text) <
                              hose.lastAmount) {
                        DialogBuilder(context).showSnackBar(t.readingError);
                        amountController.clear();
                      } else if (!value &&
                          amountValidation(
                            hose,
                            double.parse(amountController.text),
                            double.parse(readingController.text),
                          )) {
                        DialogBuilder(context).showSnackBar(
                            '${t.amountError} ${hose.measuringPointDesc}');

                        amountController.text = hose.enteredAmount.toString();
                      } else if (!value) {
                        hose.enteredAmount =
                            double.parse(amountController.text);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintText: t.egp,
                        ),
                        textAlign: TextAlign.center,
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        key: UniqueKey(),
                        onSubmitted: (value) {
                          if (double.parse(value) < hose.lastAmount) {
                            DialogBuilder(context).showSnackBar(t.readingError);
                            amountController.clear();
                          } else if (amountValidation(
                              hose,
                              double.parse(amountController.text),
                              double.parse(readingController.text))) {
                            DialogBuilder(context).showSnackBar(
                                '${t.amountError} ${hose.measuringPointDesc}');
                            amountController.text =
                                hose.enteredAmount.toString();
                          } else {
                            hose.enteredAmount =
                                double.parse(amountController.text);
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
