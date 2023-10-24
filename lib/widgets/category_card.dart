import 'package:flutter/material.dart';
import '../helpers/data/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final bool isSelected;
  late AppLocalizations t;

  CategoryCard({super.key, required this.category, required this.isSelected});

  String get getName {
    switch (category) {
      case ProductCategory.Fuel:
        return t.fuel;
      case ProductCategory.Gas:
        return t.gas;
      case ProductCategory.Oil:
        return t.oil;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    return Card(
      elevation: 2.0,
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    redColor.withOpacity(0.8),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0, 1],
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              getName,
              style: TextStyle(
                color: blueColor,
                fontFamily: 'Bebas',
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 30,
              width: 30,
              child: Image.asset(
                category.imagePath,
                color: blueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
