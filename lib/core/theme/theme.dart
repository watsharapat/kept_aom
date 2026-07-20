import 'package:flutter/material.dart';
import 'package:kept_aom/core/theme/styles.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  fontFamily: 'GoogleSans',
  fontFamilyFallback: const ['NotoEmoji'],
  cardColor: AppColors.lightSurface,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.textPrimaryOnDark,
    secondary: AppColors.primary,
    onSecondary: AppColors.textPrimaryOnDark,
    tertiary: AppColors.primary,
    onTertiary: AppColors.textPrimaryOnDark,
    error: AppColors.danger,
    onError: AppColors.textPrimaryOnDark,
    surface: AppColors.lightSurface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    shadow: AppColors.netural,
    scrim: AppColors.netural,
    inverseSurface: AppColors.darkSurface,
    onInverseSurface: AppColors.textPrimaryOnDark,
    inversePrimary: AppColors.primary,
    surfaceTint: AppColors.primary,
  ),
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: AppColors.lightSurface,
    elevation: 0,
    scrolledUnderElevation: 3,
    centerTitle: true,
    toolbarHeight: 60,
    titleSpacing: 16,
    titleTextStyle: TextStyle(
      fontFamily: 'GoogleSans',
      fontFamilyFallback: ['NotoEmoji'],
      fontSize: 20,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w800,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    actionsIconTheme: IconThemeData(color: AppColors.textPrimary),
    shape: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
  ),

  //Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryOnDark,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryOnDark,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
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
  cardTheme: CardThemeData(
    color: AppColors.lightSurface,
    shadowColor: AppColors.netural.withAlpha(50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: AppColors.lightSurface,
    headerBackgroundColor: AppColors.primary,
    headerForegroundColor: AppColors.textPrimaryOnDark,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors
            .primary; 
      }
      return AppColors
          .lightSurface; 
    }),
    dayForegroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors
            .textPrimaryOnDark; 
      }
      return AppColors
          .textPrimary; 
    }),
    todayBackgroundColor: WidgetStateProperty.all(
      AppColors.primary.withAlpha(2),
    ),
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
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.lightSurface,
    disabledColor: AppColors.disabledWidget,
    selectedColor: AppColors.primary.withAlpha(51),
    secondarySelectedColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.textPrimaryOnDark,
      fontSize: 14,
    ),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border, width: 1),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  fontFamily: 'GoogleSans',
  fontFamilyFallback: const ['NotoEmoji'],
  cardColor: AppColors.darkSurface,
  scaffoldBackgroundColor: AppColors.darkBackground,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.textPrimaryOnDark,
    secondary: AppColors.primary,
    onSecondary: AppColors.textPrimaryOnDark,
    tertiary: AppColors.primary,
    onTertiary: AppColors.textPrimaryOnDark,
    error: AppColors.danger,
    onError: AppColors.textPrimaryOnDark,
    surface: AppColors.darkSurface,
    onSurface: AppColors.textPrimaryOnDark,
    onSurfaceVariant: AppColors.textSecondaryOnDark,
    outline: AppColors.borderOnDark,
    outlineVariant: AppColors.border,
    shadow: AppColors.netural,
    scrim: AppColors.netural,
    inverseSurface: AppColors.lightSurface,
    onInverseSurface: AppColors.textPrimary,
    inversePrimary: AppColors.primary,
    surfaceTint: AppColors.primary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.textPrimaryOnDark,
    surfaceTintColor: AppColors.darkSurface,
    elevation: 0,
    scrolledUnderElevation: 3,
    centerTitle: true,
    toolbarHeight: 60,
    titleSpacing: 16,
    titleTextStyle: TextStyle(
      fontFamily: 'GoogleSans',
      fontFamilyFallback: ['NotoEmoji'],
      fontSize: 20,
      color: AppColors.textPrimaryOnDark,
      fontWeight: FontWeight.w800,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimaryOnDark),
    actionsIconTheme: IconThemeData(color: AppColors.textPrimaryOnDark),
    shape: Border(bottom: BorderSide(color: AppColors.borderOnDark, width: 1)),
  ),

  //Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryOnDark,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryOnDark,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryOnDark,
    ),
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
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: AppColors.darkSurface,
    headerBackgroundColor: AppColors.primary,
    headerForegroundColor: AppColors.textPrimaryOnDark,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors
            .primary; 
      }
      return AppColors
          .darkSurface; 
    }),
    dayForegroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors
            .textPrimaryOnDark; 
      }
      return AppColors
          .textSecondaryOnDark; 
    }),
    todayBackgroundColor: WidgetStateProperty.all(
      AppColors.primary.withAlpha(2),
    ),
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
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.darkSurface,
    disabledColor: AppColors.disabledWidget,
    selectedColor: AppColors.primary.withAlpha(51),
    secondarySelectedColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(
      color: AppColors.textPrimaryOnDark,
      fontSize: 14,
    ),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.textPrimaryOnDark,
      fontSize: 14,
    ),
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: AppColors.borderOnDark,
        width: 1,
      ),
    ),
  ),
);
