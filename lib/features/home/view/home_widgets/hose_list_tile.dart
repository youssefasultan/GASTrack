import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

import 'package:sizer/sizer.dart';

import '../../model/hose.dart';

class HoseListTile extends StatefulWidget {
  const HoseListTile({super.key});

  @override
  State<HoseListTile> createState() => _HoseListTileState();
}

class _HoseListTileState extends State<HoseListTile> {
  late FocusNode lastReadingFN;
  late FocusNode enteredReadingFN;
  late FocusNode lastAmountFN;
  late FocusNode entredAmountFN;
  late FocusNode calibraionFN;

  late TextEditingController lastReadingController;
  late TextEditingController readingController;
  late TextEditingController lastAmountController;
  late TextEditingController amountController;
  late TextEditingController calibrationController;

  @override
  void initState() {
    lastReadingController = TextEditingController();
    readingController = TextEditingController();
    lastAmountController = TextEditingController();
    amountController = TextEditingController();
    calibrationController = TextEditingController();

    lastReadingFN = FocusNode();
    enteredReadingFN = FocusNode();
    lastAmountFN = FocusNode();
    entredAmountFN = FocusNode();
    calibraionFN = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    lastReadingController.dispose();
    readingController.dispose();
    lastAmountController.dispose();
    amountController.dispose();
    calibrationController.dispose();
    lastReadingFN.dispose();
    enteredReadingFN.dispose();
    lastAmountFN.dispose();
    entredAmountFN.dispose();
    calibraionFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hose = context.getHose;

    final isAdmin = context.authProvider.isAdmin;
    final shiftType = context.authProvider.getShiftType;

    lastReadingController.text = hose.lastReading.toString();

    readingController.text =
        hose.enteredReading == 0.0 ? '' : hose.enteredReading.toString();

    lastAmountController.text = hose.lastAmount.toString();

    amountController.text =
        hose.enteredAmount == 0.0 ? '' : hose.enteredAmount.toString();

    calibrationController.text =
        hose.calibration == 0.0 ? '' : hose.calibration.toString();

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
                        style: context.theme.textTheme.titleSmall!
                            .copyWith(color: context.theme.primaryColor),
                      ),
                      Text(
                        hose.materialDesc,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                          '${context.translate.price} : ${hose.unitPrice} ${context.translate.egpPerL}'),
                    ],
                  ),
                  hose.inActiveFlag
                      ? Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Text(
                            context.translate.inActive,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Text(
                            context.translate.active,
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
                lastReadingController,
                hose,
                isAdmin,
                readingController,
                shiftType,
              ),
              // Amount Row
              if (shiftType == 'G')
                _amountRow(
                  lastAmountController,
                  hose,
                  isAdmin,
                  amountController,
                  readingController,
                  shiftType,
                ),
              // calibration row
              if (shiftType == 'F')
                _calibrationRow(
                  hose,
                  calibrationController,
                )
            ],
          ),
        ),
      ),
    );
  }

  String getUom(String mesruementUnit) {
    switch (mesruementUnit) {
      case 'L':
        return context.translate.liter;

      case 'M3':
        return context.translate.m3;
      default:
        return '';
    }
  }

  Row _calibrationRow(Hose hose, TextEditingController calibrationController) {
    return Row(
      children: [
        FittedBox(
          child: Text(
            context.translate.calibration,
            style: context.theme.textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Focus(
            onFocusChange: (value) {
              if (!value) {
                if (hose.calibrationValidation(
                    double.parse(calibrationController.text))) {
                  calibrationController.clear();
                  context.dialogBuilder.showSnackBar(
                      '${context.translate.calibError} ${hose.enteredReading - hose.lastReading}');
                } else {
                  setState(() {
                    hose.calibration = calibrationController.text.isNotEmpty
                        ? double.parse(calibrationController.text)
                        : 0.0;
                  });
                  hose.calculateHoes();
                }
              }
            },
            child: TextField(
              focusNode: calibraionFN,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                hintText: context.translate.liter,
              ),
              textAlign: TextAlign.center,
              controller: calibrationController,
              keyboardType: TextInputType.number,
              key: UniqueKey(),
              enabled: !hose.inActiveFlag,
              onTapOutside: (event) {
                calibraionFN.unfocus();
              },
              inputFormatters: [
                NumberTextInputFormatter(
                  integerDigits: 7,
                  decimalDigits: 2,
                  maxValue: '9999999.99',
                  decimalSeparator: '.',
                  
                  allowNegative: false,
                  overrideDecimalPoint: true,
                  insertDecimalPoint: false,
                  insertDecimalDigits: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row _amountRow(
      TextEditingController lastAmountController,
      Hose hose,
      bool isAdmin,
      TextEditingController amountController,
      TextEditingController readingController,
      String shiftType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 15.w,
          child: Text(
            context.translate.amount,
            style: context.theme.textTheme.bodyMedium,
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
                focusNode: lastAmountFN,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  hintText: getUom(hose.measuringUnit),
                ),
                textAlign: TextAlign.center,
                controller: lastAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                key: UniqueKey(),
                onTapOutside: (event) {
                  lastAmountFN.unfocus();
                },
                enabled: !hose.inActiveFlag,
                readOnly: !isAdmin,
              ),
            ),
          ),
        ),
        //current amount tf
        Expanded(
          child: Focus(
            onFocusChange: (value) {
              if (!value) {
                if (amountController.text.isEmpty ||
                    double.parse(amountController.text) == 0) {
                  hose.enteredAmount = 0;
                } else {
                  if (double.parse(amountController.text) < hose.lastAmount) {
                    context.dialogBuilder
                        .showSnackBar(context.translate.readingError);
                    amountController.clear();
                  } else if (hose
                      .amountValidation(double.parse(amountController.text))) {
                    context.dialogBuilder.showSnackBar(
                        '${context.translate.amountError} ${hose.measuringPointDesc}');

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
                focusNode: entredAmountFN,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  hintText: context.translate.egp,
                ),
                textAlign: TextAlign.center,
                controller: amountController,
                onTapOutside: (event) {
                  entredAmountFN.unfocus();
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                key: UniqueKey(),
                enabled: !hose.inActiveFlag,
                inputFormatters: [
                  NumberTextInputFormatter(
                    integerDigits: 7,
                    decimalDigits: 2,
                    maxValue: '9999999.99',
                    decimalSeparator: '.',
                  
                    allowNegative: false,
                    overrideDecimalPoint: true,
                    insertDecimalPoint: false,
                    insertDecimalDigits: false,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Row _readingRow(TextEditingController lastReadingController, Hose hose,
      bool isAdmin, TextEditingController readingController, String shiftType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 15.w,
          child: Text(
            context.translate.reading,
            style: context.theme.textTheme.bodyMedium,
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
                focusNode: lastReadingFN,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  hintText: getUom(hose.measuringUnit),
                ),
                textAlign: TextAlign.center,
                controller: lastReadingController,
                keyboardType: TextInputType.number,
                key: UniqueKey(),
                enabled: !hose.inActiveFlag,
                readOnly: !isAdmin,
                onTapOutside: (event) {
                  lastReadingFN.unfocus();
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
                if (readingController.text.isEmpty ||
                    double.tryParse(readingController.text) == 0) {
                  hose.enteredReading = 0;
                  hose.totalAmount = 0;
                  hose.enteredAmount = 0;
                  hose.totalQuantity = 0;

                  if (shiftType == 'F') {
                    hose.calculateHoes();
                  }
                } else {
                  if (double.parse(readingController.text) < hose.lastReading) {
                    context.dialogBuilder
                        .showSnackBar(context.translate.readingError);
                    readingController.clear();
                  } else {
                    hose.enteredReading = double.parse(readingController.text);
                    hose.totalQuantity = hose.enteredReading - hose.lastReading;
                    if (shiftType == 'F') {
                      hose.calculateHoes();
                    }
                  }
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.all(1.h),
              child: TextField(
                focusNode: enteredReadingFN,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  hintText: getUom(hose.measuringUnit),
                ),
                textAlign: TextAlign.center,
                controller: readingController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                key: UniqueKey(),
                enabled: !hose.inActiveFlag,
                onTapOutside: (event) {
                  enteredReadingFN.unfocus();
                },
                inputFormatters: [
                  NumberTextInputFormatter(
                    integerDigits: 7,
                    decimalDigits: 2,
                    maxValue: '9999999.99',
                    decimalSeparator: '.',
                    allowNegative: false,
                    overrideDecimalPoint: true,
                    insertDecimalPoint: false,
                    insertDecimalDigits: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
