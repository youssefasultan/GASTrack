import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../helpers/data/constants.dart';
import '../providers/products.dart';
import '../widgets/category_card.dart';
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
    final products = productsData.getProductsPerCategory(
        ProductCategory.values.elementAt(selectedIndex));

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
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(PaymentScreen.routeName);
            },
            icon: Padding(
              padding: const EdgeInsets.only(top: 5, right: 10),
              child: Icon(
                Icons.payment,
                color: Theme.of(context).primaryColor,
                size: 35.0,
              ),
            ),
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
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => onCardSelected(index),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.all(11.0),
                          child: CategoryCard(
                            category: ProductCategory.values.elementAt(index),
                            isSelected: selectedIndex == index,
                          ),
                        ),
                      );
                    },
                    itemCount: ProductCategory.values.length,
                  ),
                ),
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
    );
  }
}
