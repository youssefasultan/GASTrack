import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../helpers/view/dialog_builder.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  TextEditingController dateController = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    final deviceSize = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 5, left: 10),
          child: Text(
            t.adminHome,
            style: TextStyle(
              fontFamily: 'Babas',
              fontWeight: FontWeight.bold,
              color: themeData.primaryColor,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            height: deviceSize.width / 3,
            child: Center(
              child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.calendar_today), //icon of text field
                  labelText: t.enterDate, //label text of field
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate =
                      await DialogBuilder(context).showDatePickerDialog();

                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);

                    setState(() {
                      dateController.text =
                          formattedDate; //set output date to TextField value.
                    });
                  }
                },
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search),
            label: Text(t.search),
          ),
        ],
      ),
    );
  }
}
