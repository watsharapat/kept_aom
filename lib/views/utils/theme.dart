import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.indigo,
  cardColor: Colors.white,
  scaffoldBackgroundColor: const Color.fromARGB(255, 247, 247, 247),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.black87),
  ),

  //Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    displaySmall: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[800]),
    bodySmall: TextStyle(fontSize: 12, color: Colors.grey[800]),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.indigo,
      backgroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.indigo,
      backgroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: Colors.indigo,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey[50],
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[200]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    labelStyle: TextStyle(color: Colors.indigo),
    hintStyle: TextStyle(color: Colors.grey),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: Colors.indigo.shade100, // เส้นขอบ
        width: 1,
      ),
    ),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.indigo,
  cardColor: Colors.grey[850],
  scaffoldBackgroundColor: Colors.black87,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[850],
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      displaySmall: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
      bodySmall: TextStyle(fontSize: 12, color: Colors.white)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.indigo.shade400,
      backgroundColor: Colors.grey[850],
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: Colors.indigo.shade400,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white38),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white),
    ),
    labelStyle: TextStyle(color: Colors.indigo.shade300),
    hintStyle: TextStyle(color: Colors.grey.shade500),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.indigo.shade400,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    color: Colors.grey[850],
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: Colors.indigo.shade700, // เส้นขอบ
        width: 1,
      ),
    ),
  ),
);
