import 'package:flutter/material.dart';
import 'package:gas_track/helpers/extentions/context_ext.dart';
import 'package:gas_track/helpers/view/ui/pop_up_menu.dart';
import 'package:gas_track/features/home/view/home_widgets/fuel_tabbar_library.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'home_widgets/hangingunit_list_tile.dart';
import 'home_widgets/user_card.dart';
import '../../payment/view/payment_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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

      context.hangingUnitsProvider.fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final hangingUnits = context.hangingUnitsProvider.getHangingUnits;

    final shiftType = context.authProvider.getShiftType;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: Text(
            context.translate.home,
            style: TextStyle(
              fontFamily: 'Babas',
              fontWeight: FontWeight.bold,
              color: context.theme.primaryColor,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: const [
          SettingsPopUpMenu(),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: Colors.white,
                    expandedHeight: 30.h,
                    automaticallyImplyLeading: false,
                    flexibleSpace: Padding(
                      padding: EdgeInsets.all(1.h),
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: const [
                          UserCard(),
                        ],
                      ),
                    ),
                    bottom: shiftType == 'F'
                        ? HomeTabBar(
                            tabController: _tabController,
                          )
                        : null,
                  )
                ];
              },
              body: Column(
                children: [
                  if (shiftType == 'G')
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 450.h,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) =>
                              ChangeNotifierProvider.value(
                            value: hangingUnits[index],
                            child: const HangingUnitListTile(),
                          ),
                          itemCount: hangingUnits.length,
                        ),
                      ),
                    )
                  else
                    FuelTabBarLibrary(tabController: _tabController),
                ],
              ),
            ),
      floatingActionButton: Visibility(
        visible: context.mediaQuery.viewInsets.bottom == 0.0,
        child: FloatingActionButton(
          child: Icon(
            Icons.payment,
            color: context.theme.primaryColor,
            size: 35.0,
          ),
          onPressed: () {
            context.hangingUnitsProviderWithNoListner.calculateTotal();
            context.hangingUnitsProviderWithNoListner.calculateTankQuantity();
            if (shiftType == 'G') {
              var invalidHoses =
                  context.hangingUnitsProviderWithNoListner.validateProducts();

              if (invalidHoses.isNotEmpty) {
                context.dialogBuilder.showErrorDialog(
                    '${context.translate.amountError} \n ${invalidHoses.map((e) => e!.measuringPointDesc).toList().join(', ')}');
              } else if (context
                      .hangingUnitsProviderWithNoListner.getTotalSales ==
                  0.0) {
                context.dialogBuilder
                    .showErrorDialog(context.translate.totalError);
              } else {
                Navigator.of(context).pushNamed(PaymentScreen.routeName);
              }
            } else if (shiftType == 'F') {
              var unrecordedTanks =
                  context.hangingUnitsProviderWithNoListner.validateTanks();
              if (unrecordedTanks.isNotEmpty) {
                context.dialogBuilder.showErrorDialog(
                    '${context.translate.unrecoredTankError} \n ${unrecordedTanks.map((e) => e!.material).toList().join(', ')}');
              } else if (context
                      .hangingUnitsProviderWithNoListner.getTotalSales ==
                  0.0) {
                context.dialogBuilder
                    .showErrorDialog(context.translate.totalError);
              } else {
                Navigator.of(context).pushNamed(PaymentScreen.routeName);
              }
            }
          },
        ),
      ),
    );
  }
}

class HomeTabBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTabBar({
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
            text: context.translate.dispenser,
          ),
          Tab(
            text: context.translate.tank,
          ),
        ],
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: false,
        onTap: (value) {
          if (value == 1) {
            context.hangingUnitsProviderWithNoListner.calculateTotal();
            context.hangingUnitsProviderWithNoListner.calculateTankQuantity();
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
