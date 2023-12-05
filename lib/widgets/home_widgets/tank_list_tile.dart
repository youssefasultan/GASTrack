import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/tank.dart';

class TankListTile extends StatefulWidget {
  const TankListTile({super.key});

  @override
  State<TankListTile> createState() => _TankListTileState();
}

class _TankListTileState extends State<TankListTile> {
  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    // ThemeData themeData = Theme.of(context);

    final tank = Provider.of<Tank>(context);
    TextEditingController readingController = TextEditingController(
        text: tank.expectedQuantity == 0.0
            ? ''
            : tank.expectedQuantity.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: ListTile(
        key: Key(tank.material),
        title: Text('${t.fuel} ${tank.material}'),
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Bebas',
        ),
        
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Focus(
            onFocusChange: (value) {
              if (!value) {
                setState(() {
                  tank.expectedQuantity = double.parse(readingController.text);
                });
              }
            },
            child: TextField(
              controller: readingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onSubmitted: (value) {
                setState(() {
                  tank.expectedQuantity = double.parse(value);
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
