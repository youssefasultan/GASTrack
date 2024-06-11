import 'package:flutter/material.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';

import 'package:gas_track/helpers/view/ui/pop_up_menu.dart';
import 'package:gas_track/features/payment/view/payment_widgets/payment_tabbar_library.dart';
import 'package:sizer/sizer.dart';

import 'payment_widgets/payment_card.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  var _isLoading = false;
  var _isInit = true;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      context.paymentsProvider
          .fetchPayments(context.authProvider.getShiftType)
          .then((_) {
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

  @override
  Widget build(BuildContext context) {
    final paymentMethods = context.paymentsProvider.getPaymentsMethods;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate.payment,
          style: TextStyle(
            fontFamily: 'Babas',
            fontWeight: FontWeight.bold,
            color: context.theme.primaryColor,
          ),
        ),
        actions: const [
          SettingsPopUpMenu(),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                      pinned: true,
                      floating: true,
                      backgroundColor: Colors.white,
                      expandedHeight: 32.h,
                      automaticallyImplyLeading: false,
                      flexibleSpace: Padding(
                        padding: EdgeInsets.all(1.h),
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: const [
                            PaymentCard(),
                          ],
                        ),
                      ),
                      bottom: PaymentTabBar(tabController: _tabController))
                ];
              },
              body: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        PaymentTabBarLibrary(
                          tabController: _tabController,
                          paymentMethods: paymentMethods,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
      floatingActionButton: Visibility(
        visible: context.mediaQuery.viewInsets.bottom == 0.0,
        child: FloatingActionButton(
          onPressed: () {
            if (context.paymentsProvider.validatePayments()) {
              context.dialogBuilder
                  .showErrorDialog(context.translate.totalError);
            } else {
              context.dialogBuilder.showConfirmationDialog();
            }
          },
          child: Icon(
            Icons.upload,
            size: 5.h,
            color: context.theme.primaryColor,
          ),
        ),
      ),
    );
  }
}

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
