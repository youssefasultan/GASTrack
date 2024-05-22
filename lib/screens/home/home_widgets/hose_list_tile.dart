import 'package:flutter/material.dart';
import 'package:gas_track/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../../../helpers/view/dialog/dialog_builder.dart';
import '../../../models/hose.dart';

class HoseListTile extends StatefulWidget {
  const HoseListTile({super.key});

  @override
  State<HoseListTile> createState() => _HoseListTileState();
}

class _HoseListTileState extends State<HoseListTile> {
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

  bool calibrationValidation(Hose hose, double entredCalibrationAmount) {
    return entredCalibrationAmount > (hose.enteredReading - hose.lastReading);
  }

  void calculateHoes(Hose hose) {
    setState(() {
      hose.totalAmount =
          (hose.totalQuantity - hose.calibration) * hose.unitPrice;
      hose.enteredAmount = hose.lastAmount + hose.totalAmount;
    });
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

    TextEditingController calibrationController = TextEditingController(
        text: hose.calibration == 0.0 ? '' : hose.calibration.toString());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(1.h),
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
                          padding: EdgeInsets.only(right: 5.w),
                          child: Text(
                            t.inActive,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(right: 5.w),
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
              _readingRow(
                t,
                themeData,
                lastReadingController,
                hose,
                isAdmin,
                readingController,
                context,
                shiftType,
              ),
              // Amount Row
              if (shiftType == 'G')
                _amountRow(
                  t,
                  themeData,
                  lastAmountController,
                  hose,
                  isAdmin,
                  amountController,
                  context,
                  readingController,
                  shiftType,
                ),
              // calibration row
              if (shiftType == 'F')
                _calibrationRow(
                  t,
                  themeData,
                  hose,
                  calibrationController,
                )
            ],
          ),
        ),
      ),
    );
  }

  Row _calibrationRow(AppLocalizations t, ThemeData themeData, Hose hose,
      TextEditingController calibrationController) {
    return Row(
      children: [
        SizedBox(
          width: 20.w,
          child: Text(
            t.calibration,
            style: themeData.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Focus(
            onFocusChange: (value) {
              if (!value) {
                if (calibrationValidation(
                    hose, double.parse(calibrationController.text))) {
                  calibrationController.clear();
                  DialogBuilder(context).showSnackBar(
                      '${t.calibError} ${hose.enteredReading - hose.lastReading}');
                } else {
                  setState(() {
                    hose.calibration = calibrationController.text.isNotEmpty
                        ? double.parse(calibrationController.text)
                        : 0.0;
                  });
                  calculateHoes(hose);
                }
              }
            },
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                hintText: t.liter,
              ),
              textAlign: TextAlign.center,
              controller: calibrationController,
              keyboardType: TextInputType.number,
              key: UniqueKey(),
              enabled: !hose.inActiveFlag,
              onSubmitted: (value) {
                if (calibrationValidation(hose, double.parse(value))) {
                  calibrationController.clear();
                  DialogBuilder(context).showSnackBar(
                      '${t.calibError} ${hose.enteredReading - hose.lastReading}');
                } else {
                  setState(() {
                    hose.calibration =
                        value.isNotEmpty ? double.parse(value) : 0.0;
                  });
                  calculateHoes(hose);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Row _amountRow(
      AppLocalizations t,
      ThemeData themeData,
      TextEditingController lastAmountController,
      Hose hose,
      bool isAdmin,
      TextEditingController amountController,
      BuildContext context,
      TextEditingController readingController,
      String shiftType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 15.w,
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
                  hose.lastAmount = double.parse(lastAmountController.text);
                } else {
                  hose.lastAmount = 0;
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.all(1.h),
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
                enabled: !hose.inActiveFlag,
                readOnly: !isAdmin,
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
                  if (double.parse(amountController.text) < hose.lastAmount) {
                    DialogBuilder(context).showSnackBar(t.readingError);
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
                    hose.enteredAmount = double.parse(amountController.text);
                    hose.totalAmount = hose.enteredAmount - hose.lastAmount;
                  }
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.all(1.h),
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
                enabled: !hose.inActiveFlag,
                readOnly: shiftType == 'F',
                onSubmitted: (value) {
                  if (value.isEmpty) {
                    hose.enteredAmount = 0;
                  } else {
                    if (double.parse(value) < hose.lastAmount) {
                      DialogBuilder(context).showSnackBar(t.readingError);
                      amountController.clear();
                    } else if (amountValidation(
                      hose,
                      double.parse(value),
                      double.parse(readingController.text),
                    )) {
                      DialogBuilder(context).showSnackBar(
                          '${t.amountError} ${hose.measuringPointDesc}');

                      amountController.text = hose.enteredAmount.toString();
                    } else {
                      hose.enteredAmount = double.parse(value);
                      hose.totalAmount = hose.enteredAmount - hose.lastAmount;
                    }
                  }
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Row _readingRow(
      AppLocalizations t,
      ThemeData themeData,
      TextEditingController lastReadingController,
      Hose hose,
      bool isAdmin,
      TextEditingController readingController,
      BuildContext context,
      String shiftType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 15.w,
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
                  hose.lastReading = double.parse(lastReadingController.text);
                } else {
                  hose.lastReading = 0;
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.all(1.h),
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
                enabled: !hose.inActiveFlag,
                readOnly: !isAdmin,
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
                  setState(() {
                    hose.enteredReading = 0;
                    hose.totalAmount = 0;
                    hose.enteredAmount = 0;
                    if (shiftType == 'F') {
                      calculateHoes(hose);
                    }
                  });
                } else {
                  if (double.parse(readingController.text) < hose.lastReading) {
                    DialogBuilder(context).showSnackBar(t.readingError);
                    readingController.clear();
                  } else {
                    hose.enteredReading = double.parse(readingController.text);
                    hose.totalQuantity = hose.enteredReading - hose.lastReading;
                    if (shiftType == 'F') {
                      calculateHoes(hose);
                    }
                  }
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.all(1.h),
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
                enabled: !hose.inActiveFlag,
                onSubmitted: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      hose.enteredReading = 0;
                      hose.totalAmount = 0;
                      hose.enteredAmount = 0;
                      if (shiftType == 'F') {
                        calculateHoes(hose);
                      }
                    });
                  } else {
                    if (double.parse(value) < hose.lastReading) {
                      DialogBuilder(context).showSnackBar(t.readingError);
                      readingController.clear();
                    } else {
                      hose.enteredReading = double.parse(value);
                      hose.totalQuantity =
                          hose.enteredReading - hose.lastReading;

                      if (shiftType == 'F') {
                        setState(() {
                          calculateHoes(hose);
                        });
                      }
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
