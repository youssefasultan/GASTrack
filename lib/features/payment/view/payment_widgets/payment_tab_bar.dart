import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';

class PaymentTabBar extends StatelessWidget implements PreferredSizeWidget {
  const PaymentTabBar({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: TabBar(
        tabs: [
          Tab(
            text: context.translate.payment,
          ),
          Tab(
            text: context.translate.attachment,
          ),
        ],
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
