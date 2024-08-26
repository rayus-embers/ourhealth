import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  primaryColor: Colors.blueGrey,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.teal),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueGrey[900],
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.teal,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(color: Colors.white),
    bodyText2: TextStyle(color: Colors.white),
  ),
);
