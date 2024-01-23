import 'package:flutter/material.dart';
import 'package:gas_track/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../helpers/view/dialog/dialog_builder.dart';
import '../../../models/hose.dart';

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
    final diff = (reading - hose.lastReading) * hose.unitPrice;
    final expectedAmount = hose.lastAmount + diff;
    return amount != expectedAmount;
  }

  @override
  Widget build(BuildContext context) {
    final hose = Provider.of<Hose>(context);
    final authData = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authData.isAdmin;
    final shiftType = authData.getShiftType;

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
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hose.measuringPointDesc,
                        style: themeData.textTheme.titleSmall!
                            .copyWith(color: themeData.primaryColor),
                      ),
                      Text(hose.materialDesc),
                      Text('${t.price} : ${hose.unitPrice} ${t.egpPerL}'),
                    ],
                  ),
                  hose.inActiveFlag
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            t.inActive,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            t.active,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                ],
              ),
              // Reading row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 75,
                    child: Text(
                      t.reading,
                      style: themeData.textTheme.bodyMedium,
                    ),
                  ),
                  //last reading textfeild
                  Expanded(
                    child: Focus(
                      onFocusChange: (value) {
                        if (!value) {
                          if (lastReadingController.text.isNotEmpty) {
                            hose.lastReading =
                                double.parse(lastReadingController.text);
                          } else {
                            hose.lastReading = 0;
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            hintText: getUom(hose.measuringUnit, t),
                          ),
                          textAlign: TextAlign.center,
                          controller: lastReadingController,
                          keyboardType: TextInputType.number,
                          key: UniqueKey(),
                          enabled: isAdmin || shiftType == 'F'
                              ? !hose.inActiveFlag
                              : false,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              hose.lastReading = double.parse(value);
                            } else {
                              hose.lastReading = 0;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  //current reading tf
                  Expanded(
                    child: Focus(
                      onFocusChange: (value) {
                        if (!value) {
                          if (readingController.text.isEmpty) {
                            hose.enteredReading = 0;
                          } else {
                            if (double.parse(readingController.text) <=
                                hose.lastReading) {
                              DialogBuilder(context)
                                  .showSnackBar(t.readingError);
                              readingController.clear();
                            } else {
                              hose.enteredReading =
                                  double.parse(readingController.text);
                              hose.totalQuantity =
                                  hose.enteredReading - hose.lastReading;
                              if (shiftType == 'F') {
                                hose.totalAmount =
                                    hose.totalQuantity * hose.unitPrice;
                                hose.enteredAmount =
                                    hose.lastAmount + hose.totalAmount;
                              }
                            }
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            hintText: getUom(hose.measuringUnit, t),
                          ),
                          textAlign: TextAlign.center,
                          controller: readingController,
                          keyboardType: TextInputType.number,
                          key: UniqueKey(),
                          enabled: !hose.inActiveFlag,
                          onSubmitted: (value) {
                            if (value.isEmpty) {
                              hose.enteredReading = 0;
                            } else {
                              if (double.parse(value) <= hose.lastReading) {
                                DialogBuilder(context)
                                    .showSnackBar(t.readingError);
                                readingController.clear();
                              } else {
                                hose.enteredReading = double.parse(value);
                                hose.totalQuantity =
                                    hose.enteredReading - hose.lastReading;

                                if (shiftType == 'F') {
                                  hose.totalAmount =
                                      hose.totalQuantity * hose.unitPrice;
                                  hose.enteredAmount =
                                      hose.lastAmount + hose.totalAmount;
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // Amount Row
              if (shiftType == 'G')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 75,
                      child: Text(
                        t.amount,
                        style: themeData.textTheme.bodyMedium,
                      ),
                    ),
                    // last amount tf
                    Expanded(
                      child: Focus(
                        onFocusChange: (value) {
                          if (!value) {
                            if (lastAmountController.text.isNotEmpty) {
                              hose.lastAmount =
                                  double.parse(lastAmountController.text);
                            } else {
                              hose.lastAmount = 0;
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              hintText: getUom(hose.measuringUnit, t),
                            ),
                            textAlign: TextAlign.center,
                            controller: lastAmountController,
                            keyboardType: TextInputType.number,
                            key: UniqueKey(),
                            enabled: isAdmin || !hose.inActiveFlag,
                            onSubmitted: (value) {
                              hose.lastAmount = double.parse(value);
                            },
                          ),
                        ),
                      ),
                    ),
                    //current amount tf
                    Expanded(
                      child: Focus(
                        onFocusChange: (value) {
                          if (!value) {
                            if (amountController.text.isEmpty) {
                              hose.enteredAmount = 0;
                            } else {
                              if (double.parse(amountController.text) <=
                                  hose.lastAmount) {
                                DialogBuilder(context)
                                    .showSnackBar(t.readingError);
                                amountController.clear();
                              } else if (amountValidation(
                                hose,
                                double.parse(amountController.text),
                                double.parse(readingController.text),
                              )) {
                                DialogBuilder(context).showSnackBar(
                                    '${t.amountError} ${hose.measuringPointDesc}');

                                amountController.clear();
                              } else {
                                hose.enteredAmount =
                                    double.parse(amountController.text);
                              }
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              hintText: t.egp,
                            ),
                            textAlign: TextAlign.center,
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            key: UniqueKey(),
                            enabled: !hose.inActiveFlag,
                            onSubmitted: (value) {
                              if (value.isEmpty) {
                                hose.enteredAmount = 0;
                              } else {
                                if (double.parse(value) <= hose.lastAmount) {
                                  DialogBuilder(context)
                                      .showSnackBar(t.readingError);
                                  amountController.clear();
                                } else if (amountValidation(
                                  hose,
                                  double.parse(value),
                                  double.parse(readingController.text),
                                )) {
                                  DialogBuilder(context).showSnackBar(
                                      '${t.amountError} ${hose.measuringPointDesc}');

                                  amountController.text =
                                      hose.enteredAmount.toString();
                                } else {
                                  hose.enteredAmount = double.parse(value);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
