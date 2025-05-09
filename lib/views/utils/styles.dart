import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  //static const Color primary = Color(0xFF326ace);
  static const Color primary = Color(0xFF3F51B5);

  // Status Colors
  static const Color danger = Color(0xFFe11e0f);
  static const Color caution = Color(0xFFf1b32b);
  static const Color success = Color(0xFF51B155);

  // Neutral Colors
  static const Color netural = Color(0xFF131416);
  //static const Color stroke = Color(0xFF8B91A0);
  //static const Color border = Color.fromARGB(255, 231, 231, 231);
  static const Color border = Color(0xFFb8b9ba);
  //static const Color borderOnDark = Color(0xFFD9D9D9);

  static const Color lightBackground = Color.fromARGB(255, 243, 243, 243);
  static const Color darkBackground = Color(0xFF000000);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color.fromARGB(255, 28, 29, 29);

  static const Color placeholderIcon = Color(0xFF767779);
  static const Color disabledWidget = Color(0xFFababac);

  // Text Colors

  static const Color textPrimary = Color(0xFF393D3F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPlaceholder = Color(0xFF818587);
  static const Color textPrimaryOnDark = Color(0xFFFFFFFF);
  static const Color textSecondaryOnDark = Color(0xFFE0E0E0);

  // Semantic Color Additions
  static const Color transparent = Color(0x00000000);
  static const Color overlay = Color(0x80000000);
}

class AppTextStyle {
  static const TextStyle captionOnLight = TextStyle(
    fontSize: 12,
    color: AppColors.textPrimary,
  );

  static const TextStyle captionOnDark = TextStyle(
    fontSize: 12,
    color: AppColors.textPrimaryOnDark,
  );

  static const TextStyle bodyOnLight = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyOnDark = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimaryOnDark,
  );

  static const TextStyle subtitleOnLight = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle subtitleOnDark = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondaryOnDark,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headingOnLight = TextStyle(
    fontSize: 24,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle headingOnDark = TextStyle(
    fontSize: 24,
    color: AppColors.textPrimaryOnDark,
    fontWeight: FontWeight.w800,
  );
}
