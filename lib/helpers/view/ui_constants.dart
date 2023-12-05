// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// colors
Color redColor = const Color.fromRGBO(250, 70, 22, 1);
Color blueColor = const Color.fromRGBO(0, 48, 135, 1);

final LinearGradient linerGradient = LinearGradient(
  colors: [
    blueColor.withOpacity(0.5),
    redColor.withOpacity(0.8),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: const [0, 1],
);
//TODO: complete and map theme data
final ThemeData myTheme = ThemeData(
  hintColor: Colors.black38,
  fontFamily: 'Bebas',
  primaryColor: blueColor,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: blueColor).copyWith(
    primary: blueColor,
    secondary: redColor,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
      color: blueColor,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: blueColor,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: blueColor,
    ),
    labelLarge: TextStyle(
      fontSize: 25,
      color: blueColor,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(
      fontSize: 18,
      color: blueColor,
    ),
    labelSmall: const TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    bodyLarge: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: blueColor,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
  ),
);
