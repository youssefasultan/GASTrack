import 'package:flutter/material.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';
import 'package:gas_track/helpers/view/ui/ui_constants.dart';
import 'package:sizer/sizer.dart';

class TankListTile extends StatefulWidget {
  const TankListTile({super.key});

  @override
  State<TankListTile> createState() => _TankListTileState();
}

class _TankListTileState extends State<TankListTile> {
  late FocusNode startFN;
  late FocusNode endFN;
  late FocusNode waredFN;
  late TextEditingController shiftStartController;
  late TextEditingController shifEndController;
  late TextEditingController waredController;

  @override
  void initState() {
    shiftStartController = TextEditingController();
    shifEndController = TextEditingController();
    waredController = TextEditingController();

    startFN = FocusNode();
    endFN = FocusNode();
    waredFN = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    shiftStartController.dispose();
    shifEndController.dispose();
    waredController.dispose();
    startFN.dispose();
    endFN.dispose();
    waredFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tank = context.getTank;

    final isAdmin = context.authProvider.isAdmin;

    shiftStartController.text =
        tank.shiftStart == 0.0 ? '0.0' : tank.shiftStart.toString();
    shifEndController.text =
        tank.shiftEnd == 0.0 ? '' : tank.shiftEnd.toString();

    waredController.text = tank.waredQty == 0.0 ? '' : tank.waredQty.toString();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      height: 30.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: context.theme.primaryColorLight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${context.translate.fuel} ${tank.material}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: blueColor,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${context.translate.quantity} : ${tank.quantity} ${context.translate.liter}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: blueColor,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${context.translate.amount} : ${tank.amount} ${context.translate.egp}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: blueColor,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.all(1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Focus(
                  onFocusChange: (value) {
                    if (!value) {
                      tank.shiftStart = shiftStartController.text.isNotEmpty
                          ? double.parse(shiftStartController.text)
                          : 0.0;
                    }
                  },
                  child: SizedBox(
                    width: 30.w,
                    height: 7.h,
                    child: TextField(
                      focusNode: startFN,
                      controller: shiftStartController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        hintText: context.translate.start,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onTapOutside: (event) {
                        startFN.unfocus();
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      readOnly: isAdmin ? false : !(tank.shiftStart == 0.0),
                      onSubmitted: (value) {
                        setState(() {
                          tank.shiftStart =
                              value.isNotEmpty ? double.parse(value) : 0.0;
                        });
                      },
                    ),
                  ),
                ),
                Focus(
                  onFocusChange: (value) {
                    if (!value) {
                      tank.shiftEnd = shifEndController.text.isNotEmpty
                          ? double.parse(shifEndController.text)
                          : 0.0;
                    }
                  },
                  child: SizedBox(
                    width: 30.w,
                    height: 7.h,
                    child: TextField(
                      focusNode: endFN,
                      controller: shifEndController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        hintText: context.translate.end,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onTapOutside: (event) => endFN.unfocus(),
                      onSubmitted: (value) {
                        setState(() {
                          tank.shiftEnd =
                              value.isNotEmpty ? double.parse(value) : 0.0;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.all(1.h),
            child: Focus(
              onFocusChange: (value) {
                if (!value) {
                  tank.waredQty = waredController.text.isNotEmpty
                      ? double.parse(waredController.text)
                      : 0.0;
                }
              },
              child: SizedBox(
                width: 50.w,
                child: TextField(
                  focusNode: waredFN,
                  controller: waredController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    hintText: context.translate.wared,
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  onTapOutside: (event) => waredFN.unfocus(),
                  textAlign: TextAlign.center,
                  onSubmitted: (value) {
                    setState(() {
                      tank.waredQty =
                          value.isNotEmpty ? double.parse(value) : 0.0;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
