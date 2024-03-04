import 'package:flutter/material.dart';
import 'package:gas_track/helpers/view/ui/ui_constants.dart';
import 'package:gas_track/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/tank.dart';

class TankListTile extends StatefulWidget {
  const TankListTile({super.key});

  @override
  State<TankListTile> createState() => _TankListTileState();
}

class _TankListTileState extends State<TankListTile> {
  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    final contentSize = MediaQuery.of(context).size;
    final tank = Provider.of<Tank>(context);

    final authData = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authData.isAdmin;

    TextEditingController shiftStartController = TextEditingController(
        text: tank.shiftStart == 0.0 ? '0.0' : tank.shiftStart.toString());
    TextEditingController shifEndController = TextEditingController(
        text: tank.shiftEnd == 0.0 ? '' : tank.shiftEnd.toString());

    TextEditingController waredController = TextEditingController(
        text: tank.waredQty == 0.0 ? '' : tank.waredQty.toString());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      height: contentSize.height * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).primaryColorLight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${t.fuel} ${tank.material}',
                style: TextStyle(
                  fontSize: 20,
                  color: blueColor,
                  fontFamily: 'Bebas',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${t.quantity} : ${tank.quantity} ${t.liter}',
                    style: TextStyle(
                      fontSize: 18,
                      color: blueColor,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${t.amount} : ${tank.amount} ${t.egp}',
                    style: TextStyle(
                      fontSize: 18,
                      color: blueColor,
                      fontFamily: 'Bebas',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                    width: contentSize.width * 0.3,
                    height: 60,
                    child: TextField(
                      controller: shiftStartController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        hintText: t.start,
                      ),
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
                    width: contentSize.width * 0.3,
                    height: 60,
                    child: TextField(
                      controller: shifEndController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        hintText: t.end,
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Focus(
              onFocusChange: (value) {
                if (!value) {
                  tank.waredQty = waredController.text.isNotEmpty
                      ? double.parse(waredController.text)
                      : 0.0;
                }
              },
              child: SizedBox(
                width: contentSize.width * 0.6,
                height: 60,
                child: TextField(
                  controller: waredController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    hintText: t.wared,
                  ),
                  keyboardType: TextInputType.number,
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
