import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/helpers/view/ui/pop_up_menu.dart';
import 'package:gas_track/screens/home/home_widgets/fuel_tabbar_library.dart';
import 'package:provider/provider.dart';

import '../../helpers/view/dialog/dialog_builder.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hanging_unit_provider.dart';
import 'home_widgets/hangingunit_list_tile.dart';
import 'home_widgets/user_card.dart';
import '../payment/payment_screen.dart';

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

      Provider.of<HangingUnitsProvider>(context).fetchProducts().then((_) {
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
    var t = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);

    final hangingUnitsData = Provider.of<HangingUnitsProvider>(context);

    final hangingUnits = hangingUnitsData.getHangingUnits;

    final shiftType =
        Provider.of<AuthProvider>(context, listen: false).getShiftType;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 5, left: 10),
          child: Text(
            t.home,
            style: TextStyle(
              fontFamily: 'Babas',
              fontWeight: FontWeight.bold,
              color: themeData.primaryColor,
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
          : Column(
              children: [
                const UserCard(),
                if (shiftType == 'G')
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: 450,
                      child: ListView.builder(
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
                  Expanded(
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(
                              text: t.dispenser,
                            ),
                            Tab(
                              text: t.tank,
                            ),
                          ],
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          onTap: (value) {
                            if (value == 1) {
                              hangingUnitsData.calculateTankQuantity();
                            }
                          },
                        ),
                        FuelTabBarLibrary(tabController: _tabController),
                      ],
                    ),
                  ),
              ],
            ),
      floatingActionButton: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
        child: FloatingActionButton(
          child: Icon(
            Icons.payment,
            color: themeData.primaryColor,
            size: 35.0,
          ),
          onPressed: () {
            hangingUnitsData.calculateTotal();
            hangingUnitsData.calculateTankQuantity();
            if (shiftType == 'G') {
              var invalidHoses = hangingUnitsData.validateProducts();

              if (invalidHoses.isNotEmpty) {
                DialogBuilder(context).showErrorDialog(
                    '${t.amountError} \n ${invalidHoses.map((e) => e!.measuringPointDesc).toList().join(', ')}');
              } else if (hangingUnitsData.getTotalSales == 0.0) {
                DialogBuilder(context).showErrorDialog(t.totalError);
              } else {
                Navigator.of(context).pushNamed(PaymentScreen.routeName);
              }
            } else if (shiftType == 'F') {
              var unrecordedTanks = hangingUnitsData.validateTanks();
              if (unrecordedTanks.isNotEmpty) {
                DialogBuilder(context).showErrorDialog(
                    '${t.unrecoredTankError} \n ${unrecordedTanks.map((e) => e!.material).toList().join(', ')}');
              } else if (hangingUnitsData.getTotalSales == 0.0) {
                DialogBuilder(context).showErrorDialog(t.totalError);
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
