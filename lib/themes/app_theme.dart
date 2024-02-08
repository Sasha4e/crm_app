// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      backgroundColor: Color(0xFF030332),
      foregroundColor: Colors.white,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Color(0xFF030332),
    ),
  );
}
