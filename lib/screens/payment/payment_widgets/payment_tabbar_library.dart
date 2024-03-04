import 'package:flutter/material.dart';
import 'package:gas_track/models/payment.dart';
import 'package:gas_track/screens/payment/payment_widgets/attachment_view.dart';
import 'package:provider/provider.dart';

import 'payment_list_tile.dart';

class PaymentTabBarLibrary extends StatelessWidget {
  final TabController tabController;
  final List<Payment> paymentMethods;
  const PaymentTabBarLibrary(
      {super.key, required this.tabController, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        controller: tabController,
        children: [
          //payment view
          ListView.builder(
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: paymentMethods[index],
              child: const PaymentTile(),
            ),
            itemCount: paymentMethods.length,
          ),
          // attachment View
          const AttachmentView(),
        ],
      ),
    );
  }
}
