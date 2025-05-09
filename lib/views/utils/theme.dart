import 'package:flutter/material.dart';
import 'package:kept_aom/views/utils/styles.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  cardColor: AppColors.lightSurface,
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    titleTextStyle: AppTextStyle.subtitleOnLight,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  ),

  //Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryOnDark),
    displayMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryOnDark),
    displaySmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.textPrimary),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.lightSurface,
      textStyle: AppTextStyle.subtitleOnDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.lightSurface,
      textStyle: AppTextStyle.subtitleOnDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      iconSize: 20,
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.lightSurface,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    outlineBorder: const BorderSide(color: AppColors.border),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    labelStyle: AppTextStyle.subtitleOnLight,
    hintStyle: AppTextStyle.subtitleOnLight,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.lightSurface,
  ),
  cardTheme: CardTheme(
    color: AppColors.lightSurface,
    shadowColor: AppColors.netural.withAlpha(50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: AppColors.lightSurface,
    headerBackgroundColor: AppColors.primary,
    headerForegroundColor: AppColors.textPrimaryOnDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary; // สีพื้นหลังของวันที่เลือก
        }
        return AppColors.lightSurface; // สีพื้นหลังของวันที่ปกติ
      },
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.textPrimaryOnDark; // สีตัวอักษรของวันที่เลือก
        }
        return AppColors.textPrimary; // สีตัวอักษรของวันที่ปกติ
      },
    ),
    todayBackgroundColor:
        WidgetStateProperty.all(AppColors.primary.withAlpha(2)),
    todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
    cancelButtonStyle: TextButton.styleFrom(
      textStyle: AppTextStyle.bodyOnLight,
      foregroundColor: AppColors.textSecondary,
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTextStyle.bodyOnLight.copyWith(fontWeight: FontWeight.bold),
    ),
    rangePickerHeaderBackgroundColor: AppColors.primary,
    rangePickerBackgroundColor: AppColors.primary,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  cardColor: AppColors.darkSurface,
  scaffoldBackgroundColor: AppColors.darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    titleTextStyle: AppTextStyle.subtitleOnDark,
    iconTheme: IconThemeData(color: AppColors.textPrimaryOnDark),
  ),

  //Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryOnDark),
    displayMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryOnDark),
    displaySmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryOnDark),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryOnDark),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimaryOnDark),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.textPrimaryOnDark),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.darkSurface,
      textStyle: AppTextStyle.subtitleOnDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.darkSurface,
      textStyle: AppTextStyle.subtitleOnDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      iconSize: 20,
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.darkSurface,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    labelStyle: AppTextStyle.subtitleOnDark,
    hintStyle: AppTextStyle.subtitleOnDark,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textPrimaryOnDark,
  ),
  cardTheme: CardTheme(
    color: AppColors.darkSurface,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      // side: const BorderSide(color: AppColors.border, width: 1),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: AppColors.darkSurface,
    headerBackgroundColor: AppColors.primary,
    headerForegroundColor: AppColors.textPrimaryOnDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary; // สีพื้นหลังของวันที่เลือก
        }
        return AppColors.darkSurface; // สีพื้นหลังของวันที่ปกติ
      },
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.textPrimaryOnDark; // สีตัวอักษรของวันที่เลือก
        }
        return AppColors.textSecondaryOnDark; // สีตัวอักษรของวันที่ปกติ
      },
    ),
    todayBackgroundColor:
        WidgetStateProperty.all(AppColors.primary.withAlpha(2)),
    todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
    cancelButtonStyle: TextButton.styleFrom(
      textStyle: AppTextStyle.bodyOnDark,
      foregroundColor: AppColors.textSecondaryOnDark,
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTextStyle.bodyOnDark.copyWith(fontWeight: FontWeight.bold),
    ),
    rangePickerHeaderBackgroundColor: AppColors.primary,
    rangePickerBackgroundColor: AppColors.primary,
  ),
);
