import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.greenAccent,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: Colors.redAccent),
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.greenAccent,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.redAccent,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(color: Colors.black),
    bodyText2: TextStyle(color: Colors.black),
  ),
);

