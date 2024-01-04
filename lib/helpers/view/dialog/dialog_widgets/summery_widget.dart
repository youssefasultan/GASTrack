import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../ui/dash_separator.dart';
import '../dialog_builder.dart';
import '../../../../providers/payments_provider.dart';

class SummeryWidget extends StatefulWidget {
  const SummeryWidget({
    super.key,
  });

  @override
  State<SummeryWidget> createState() => _SummeryWidgetState();
}

class _SummeryWidgetState extends State<SummeryWidget> {
  var _isLoading = false;
  var _isInit = true;
  late AppLocalizations t;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<PaymentsProvider>(context)
          .getEndOfDaySummeryPayments()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        DialogBuilder(context).showErrorDialog(error.toString());
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  String getTitle(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'coupon':
        return t.coupon;
      case 'visa':
        return t.card;
      case 'cash':
        return t.cash;
      case 'unpaid coupons':
        return t.unpaidCoupons;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    t = AppLocalizations.of(context)!;
    // ThemeData themeData = Theme.of(context);

    final summeryData = Provider.of<PaymentsProvider>(context, listen: false);
    final summeryItems = summeryData.getSummery;
    final summryTotal = summeryData.getSummeryTotals;

    return SizedBox(
      height: deviceSize.height * 0.7,
      width: deviceSize.width,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text(
                    t.daySummery,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Bebas',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const DashSeparator(),
                Expanded(
                  child: ListView(
                    children: [
                      DataTable(
                        columns: [
                          DataColumn(label: Text(t.shift)),
                          DataColumn(label: Text(t.payment)),
                          DataColumn(label: Text(t.amount))
                        ],
                        rows: summeryItems
                            .map((e) => DataRow(
                                  cells: [
                                    DataCell(Text(e.shift)),
                                    DataCell(Text(getTitle(e.paymentType))),
                                    DataCell(Text(e.value.toString())),
                                  ],
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const DashSeparator(),
                Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height * 0.25,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${t.total} ${getTitle(summryTotal.keys.elementAt(index))}',
                              style: TextStyle(
                                fontFamily: 'Bebas',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              '${summryTotal.values.elementAt(index)} ${t.egp}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: summryTotal.length,
                  ),
                ),
              ],
            ),
    );
  }
}
