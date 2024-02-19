import 'package:flutter/material.dart';
import 'package:gas_track/providers/payments_provider.dart';
import 'package:gas_track/screens/payment/payment_widgets/attachment_view.dart';
import 'package:provider/provider.dart';

import 'payment_list_tile.dart';

class PaymentTabBarLibrary extends StatefulWidget {
  final TabController tabController;
  const PaymentTabBarLibrary({super.key, required this.tabController});

  @override
  State<PaymentTabBarLibrary> createState() => _PaymentTabBarLibraryState();
}

class _PaymentTabBarLibraryState extends State<PaymentTabBarLibrary> {
  @override
  Widget build(BuildContext context) {
    final paymentsData = Provider.of<PaymentsProvider>(context);
    final paymentMethods = paymentsData.getPaymentsMethods;
    return Expanded(
      child: TabBarView(
        controller: widget.tabController,
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
