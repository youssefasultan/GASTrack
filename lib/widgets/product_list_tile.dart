// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/data/constants.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import '../helpers/view/dialog_builder.dart';

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
    final productsData = Provider.of<Products>(context);
    final product = Provider.of<Product>(context);
    t = AppLocalizations.of(context)!;

    TextEditingController readingController =
        TextEditingController(text: product.enteredReading.toString());

    TextEditingController amountController = TextEditingController();

    if (productsData.isUpdated) {
      readingController.clear();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: ExpansionTile(
        key: UniqueKey(),
        title: Text(
          product.equipmentDesc,
          style: TextStyle(
            fontFamily: 'Bebas',
            color: Theme.of(context).primaryColor,
          ),
        ),
        subtitle: Text(product.materialDesc),
        collapsedBackgroundColor: Theme.of(context).primaryColorLight,
        backgroundColor: Theme.of(context).primaryColorLight,
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
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      '${product.lastReading} ${getUom(product.measuringUnit)}',
                      textAlign: TextAlign.center,
                      key: UniqueKey(),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: redColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (value) {
                      if (value && product.enteredReading == 0.0) {
                        readingController.clear();
                      } else if (!value &&
                          double.parse(readingController.text) <
                              product.lastReading) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.readingError),
                          ),
                        );
                      } else if (!value) {
                        product.enteredReading =
                            double.parse(readingController.text);
                        product.quantity =
                            product.enteredReading - product.lastReading;
                      }
                    },
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
                          DialogBuilder(context)
                              .showErrorDialog(t.readingError);
                        } else {
                          product.enteredReading = double.parse(value);
                          product.quantity =
                              product.enteredReading - product.lastReading;
                        }
                      },
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
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      '${product.lastAmount} ${t.egp}',
                      textAlign: TextAlign.center,
                      key: UniqueKey(),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: redColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (value) {
                      if (value && product.enteredAmount == 0.0) {
                        readingController.clear();
                      } else if (!value &&
                          double.parse(amountController.text) <
                              product.lastAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.readingError),
                          ),
                        );
                      } else if (!value &&
                          amountValidation(
                              product,
                              double.parse(amountController.text),
                              double.parse(readingController.text))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.amount),
                          ),
                        );
                      } else if (!value) {
                        product.enteredAmount =
                            double.parse(amountController.text);
                      }
                    },
                    child: TextField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        hintText: getUom(product.measuringUnit),
                      ),
                      textAlign: TextAlign.center,
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      key: UniqueKey(),
                      onSubmitted: (value) {
                        if (double.parse(value) < product.lastAmount) {
                          DialogBuilder(context)
                              .showErrorDialog(t.readingError);
                        } else if (
                          amountValidation(
                              product,
                              double.parse(amountController.text),
                              double.parse(readingController.text))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.amountError),
                          ),
                        );
                      } else {
                        product.enteredAmount =
                            double.parse(amountController.text);
                      }
                      },
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
