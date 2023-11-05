import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import 'product_list_tile.dart';
import 'tank_list_tile.dart';

class FuelTabBarLibrary extends StatefulWidget {
  final TabController tabController;
  const FuelTabBarLibrary({
    super.key,
    required this.tabController,
  });

  @override
  State<FuelTabBarLibrary> createState() => _FuelTabBarLibraryState();
}

class _FuelTabBarLibraryState extends State<FuelTabBarLibrary> {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final productsList = productsData.getProducts;
    final tanksList = productsData.getTanks;

    return Expanded(
      child: TabBarView(
        controller: widget.tabController,
        children: [
          ListView.builder(
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: productsList[index],
              child: ProductListTile(),
            ),
            itemCount: productsList.length,
          ),
          ListView.builder(
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: tanksList[index],
              child: const TankListTile(),
            ),
            itemCount: tanksList.length,
          ),
        ],
      ),
    );
  }
}
