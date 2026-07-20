import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3F51B5);

  // Status Colors
  static const Color danger = Color(0xFFe11e0f);
  static const Color caution = Color(0xFFf1b32b);
  static const Color success = Color(0xFF51B155);

  // Neutral Colors
  static const Color netural = Color(0xFF131416);
  static const Color border = Color(0xFFEEEEEE);
  static const Color borderOnDark = Color(0x1F9EA3AE);

  static const Color lightBackground = Color.fromARGB(255, 243, 243, 243);
  static const Color darkBackground = Color(0xFF0E1116);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF181C24);

  static const Color placeholderIcon = Color(0xFF767779);
  static const Color disabledWidget = Color(0xFFababac);

  // Text Colors
  static const Color textPrimary = Color(0xFF393D3F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPlaceholder = Color(0xFF818587);
  static const Color textPrimaryOnDark = Color(0xFFF0F2F5);
  static const Color textSecondaryOnDark = Color(0xFF9EA3AE);

  // Semantic Color Additions
  static const Color transparent = Color(0x00000000);
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Colors.black12;
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

class AppStyles {
  static const double cardRadiusValue = 24.0;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(cardRadiusValue),
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
  ];

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: cardBorderRadius,
      border: Border.all(
        color: Theme.of(context).colorScheme.outline,
        width: 1,
      ),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration pillDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.netural
          : AppColors.lightBackground,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline,
        width: 1,
      ),
    );
  }
}

class AppBarGradientBackground extends StatelessWidget {
  const AppBarGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final glowColor = AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glowColor, baseColor, baseColor],
          stops: const [0.0, 0.48, 1.0],
        ),
      ),
    );
  }
}
