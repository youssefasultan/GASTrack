// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:gas_track/helpers/view/dialog_builder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/product.dart';
import '../providers/auth.dart';

class ProductListTile extends StatelessWidget {
  ProductListTile({super.key});
  late AppLocalizations t;

  String getUom(String mesruementUnit) {
    switch (mesruementUnit) {
      case 'L':
        return t.liter;

      case 'M3':
        return t.m3;
      default:
        return '';
    }
  }

  bool amountValidation(Product product, double amount, double reading) {
    return (amount - product.lastAmount) !=
        ((reading - product.lastReading) * product.unitPrice);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final isAdmin = Provider.of<Auth>(context, listen: false).isAdmin;
    t = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);

    TextEditingController lastReadingController =
        TextEditingController(text: product.lastReading.toString());

    TextEditingController readingController = TextEditingController(
        text: product.enteredReading == 0.0
            ? ''
            : product.enteredReading.toString());

    TextEditingController lastAmountController =
        TextEditingController(text: product.lastAmount.toString());

    TextEditingController amountController = TextEditingController(
        text: product.enteredAmount == 0.0
            ? ''
            : product.enteredAmount.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: ExpansionTile(
        key: UniqueKey(),
        title: Text(
          product.equipmentDesc,
          style: TextStyle(
            fontFamily: 'Bebas',
            color: themeData.primaryColor,
          ),
        ),
        subtitle: Text(product.materialDesc),
        collapsedBackgroundColor: themeData.primaryColorLight,
        backgroundColor: themeData.primaryColorLight,
        expandedAlignment: Alignment.center,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50))),
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
                        product.lastReading =
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
                          hintText: getUom(product.measuringUnit),
                        ),
                        textAlign: TextAlign.center,
                        controller: lastReadingController,
                        keyboardType: TextInputType.number,
                        key: UniqueKey(),
                        enabled: isAdmin,
                        onSubmitted: (value) {
                          product.lastReading = double.parse(value);
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
                              product.lastReading) {
                        DialogBuilder(context).showSnackBar(t.readingError);
                        readingController.clear();
                      } else if (!value) {
                        product.enteredReading =
                            double.parse(readingController.text);
                        product.quantity =
                            product.enteredReading - product.lastReading;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintText: getUom(product.measuringUnit),
                        ),
                        textAlign: TextAlign.center,
                        controller: readingController,
                        keyboardType: TextInputType.number,
                        key: UniqueKey(),
                        onSubmitted: (value) {
                          if (double.parse(value) < product.lastReading) {
                            DialogBuilder(context).showSnackBar(t.readingError);
                            readingController.clear();
                          } else {
                            product.enteredReading = double.parse(value);
                            product.quantity =
                                product.enteredReading - product.lastReading;
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
                        product.lastAmount =
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
                          hintText: getUom(product.measuringUnit),
                        ),
                        textAlign: TextAlign.center,
                        controller: lastAmountController,
                        keyboardType: TextInputType.number,
                        key: UniqueKey(),
                        enabled: isAdmin,
                        onSubmitted: (value) {
                          product.lastAmount = double.parse(value);
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
                              product.lastAmount) {
                        DialogBuilder(context).showSnackBar(t.readingError);
                        amountController.clear();
                      } else if (!value &&
                          amountValidation(
                            product,
                            double.parse(amountController.text),
                            double.parse(readingController.text),
                          )) {
                        DialogBuilder(context).showSnackBar(
                            '${t.amountError} ${product.equipmentDesc}');

                        amountController.text =
                            product.enteredAmount.toString();
                      } else if (!value) {
                        product.enteredAmount =
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
                          if (double.parse(value) < product.lastAmount) {
                            DialogBuilder(context).showSnackBar(t.readingError);
                            amountController.clear();
                          } else if (amountValidation(
                              product,
                              double.parse(amountController.text),
                              double.parse(readingController.text))) {
                            DialogBuilder(context).showSnackBar(
                                '${t.amountError} ${product.equipmentDesc}');
                            amountController.text =
                                product.enteredAmount.toString();
                          } else {
                            product.enteredAmount =
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
