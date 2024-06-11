import 'package:flutter/material.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';

import '../../ui/dash_separator.dart';

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

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      context.paymentsProvider.getEndOfDaySummeryPayments().then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        context.dialogBuilder.showErrorDialog(error.toString());
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  String getTitle(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'coupon':
        return context.translate.coupon;
      case 'visa':
        return context.translate.card;
      case 'cash':
        return context.translate.cash;
      case 'credit':
        return context.translate.unpaidCoupons;
      case 'smartcards':
        return context.translate.smartCard;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.mediaQuery.size;

    final summeryData = context.paymentsProviderWithNoListner;
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
                    context.translate.daySummery,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.theme.primaryColor,
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
                          DataColumn(label: Text(context.translate.shift)),
                          DataColumn(label: Text(context.translate.payment)),
                          DataColumn(label: Text(context.translate.amount))
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
                  height: context.mediaQuery.size.height * 0.26,
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
                              '${context.translate.total} ${getTitle(summryTotal.keys.elementAt(index))}',
                              style: TextStyle(
                                fontFamily: 'Bebas',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.theme.primaryColor,
                              ),
                            ),
                            Text(
                              '${summryTotal.values.elementAt(index)} ${context.translate.egp}',
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
