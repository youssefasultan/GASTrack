// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// enums
enum AuthMode { Admin, Login }

enum ProductCategory {
  Fuel(1, 'fuel', 'assets/images/fuel.png'),
  Gas(1, 'gas', 'assets/images/gas.png');
  // Oil(1, 'oil', 'assets/images/oil.png');

  final int id;
  final String name;
  final String imagePath;

  const ProductCategory(this.id, this.name, this.imagePath);
}

// colors
Color redColor = const Color.fromRGBO(250, 70, 22, 1);
Color blueColor = const Color.fromRGBO(0, 48, 135, 1);
