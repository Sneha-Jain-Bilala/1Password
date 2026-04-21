import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.textTheme.bodyMedium?.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimary: AppColors.lightOnPrimary,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSecondary,
        tertiary: AppColors.lightTertiary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        surfaceContainerLow: AppColors.lightSurfaceContainerLow,
        surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
        surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
        outlineVariant: AppColors.lightOutlineVariant,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppTextStyles.textTheme.copyWith(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.lightOnSurface,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.lightOnSurface,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.lightOnSurface,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.lightTertiary,
        ), // Tertiary anchor
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.lightTertiary,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.lightOnSurface,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.lightOnSurface,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.lightOnSurface,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightOnSurfaceVariant,
        ), // Secondary metadata
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.lightOnSurfaceVariant,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.lightOnSurface,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.lightOnSurfaceVariant,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.lightOnSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.textTheme.bodyMedium?.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        secondary: AppColors.darkSecondary,
        tertiaryContainer: AppColors.darkTertiaryContainer,
        onTertiaryContainer: AppColors.darkOnTertiaryContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
        surfaceContainerLow: AppColors.darkSurfaceContainerLow,
        surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
        outlineVariant: AppColors.darkOutlineVariant,
        error: AppColors.darkTertiaryContainer,
      ),
      scaffoldBackgroundColor: AppColors.darkSurface,
      textTheme: AppTextStyles.textTheme.copyWith(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.darkOnSurface,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.darkOnSurface,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.darkOnSurface,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkOnSurface,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkOnSurface,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkOnSurface,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.darkOnSurface,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimaryFixed, // Text on primary
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ), // 14dp roundness for buttons in dark theme
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ), // 20dp for cards
      ),
    );
  }
}
