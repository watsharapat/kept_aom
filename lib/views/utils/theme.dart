import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.indigo,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.indigo,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
    displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.indigo.shade700),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[600]),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.indigo,
      backgroundColor: Colors.white,
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.indigo),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.indigo, width: 2),
    ),
    labelStyle: TextStyle(color: Colors.indigo),
    hintStyle: TextStyle(color: Colors.grey),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.indigo,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.indigo.shade700,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.indigo.shade100),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white54),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.indigo.shade400,
      backgroundColor: Colors.grey[800],
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.indigo.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.indigo.shade300, width: 2),
    ),
    labelStyle: TextStyle(color: Colors.indigo.shade300),
    hintStyle: TextStyle(color: Colors.grey.shade500),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.indigo.shade400,
    foregroundColor: Colors.white,
  ),
);
