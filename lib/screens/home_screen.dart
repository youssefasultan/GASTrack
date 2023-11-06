import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/helpers/view/dialog_builder.dart';
import 'package:gas_track/widgets/fuel_tabbar_library.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/products.dart';
import '../widgets/product_list_tile.dart';
import '../widgets/user_card.dart';
import 'payment_screen.dart';

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

      Provider.of<Products>(context).fetchProducts().then((_) {
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

    final productsData = Provider.of<Products>(context);

    final products = productsData.getProducts;

    final shiftType = Provider.of<Auth>(context, listen: false).getShiftType;

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
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: themeData.primaryColor,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
                Provider.of<Auth>(context, listen: false).logout();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: themeData.primaryColor,
                      size: 30.0,
                    ),
                    Text(
                      t.logout,
                      style: TextStyle(
                        fontSize: 18,
                        color: themeData.primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
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
                      child: ListView.builder(
                    itemBuilder: (context, index) =>
                        ChangeNotifierProvider.value(
                      value: products[index],
                      child: ProductListTile(),
                    ),
                    itemCount: products.length,
                  ))
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
                              productsData.calculateTankQuantity();
                            }
                          },
                        ),
                        FuelTabBarLibrary(tabController: _tabController),
                      ],
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.payment,
          color: themeData.primaryColor,
          size: 35.0,
        ),
        onPressed: () {
          productsData.calculateTotal();
          var product = productsData.validateProducts();
          if (productsData.getTotalSales == 0.0) {
            DialogBuilder(context).showErrorDialog(t.totalError);
          } else if (product != null) {
            DialogBuilder(context)
                .showErrorDialog('${t.amountError} ${product.equipmentDesc}');
          } else {
            Navigator.of(context).pushNamed(PaymentScreen.routeName);
          }
        },
      ),
    );
  }
}
