import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gas_track/helpers/view/dialog_builder.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  var _isLoading = false;
  var _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  void onCardSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
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

    final productsData = Provider.of<Products>(context);

    final products = productsData.getProducts();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 5, left: 10),
          child: Text(
            t.home,
            style: TextStyle(
              fontFamily: 'Babas',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryColor,
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
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                    Text(
                      t.logout,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
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
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) =>
                        ChangeNotifierProvider.value(
                      value: products[index],
                      child: ProductListTile(),
                    ),
                    itemCount: products.length,
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.payment,
          color: Theme.of(context).primaryColor,
          size: 35.0,
        ),
        onPressed: () {
          productsData.calculateTotal();

          if (productsData.getTotalSales == 0.0) {
            DialogBuilder(context).showErrorDialog(t.totalError);
          } else {
            Navigator.of(context).pushNamed(PaymentScreen.routeName);
          }
        },
      ),
    );
  }
}
