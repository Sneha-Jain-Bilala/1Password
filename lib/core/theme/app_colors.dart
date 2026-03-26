import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme
  static const Color darkSurface = Color(0xFF13121B);
  static const Color darkSurfaceContainerLowest = Color(0xFF0E0D16);
  static const Color darkSurfaceContainerLow = Color(0xFF1C1A24); // Fallback
  static const Color darkSurfaceContainer = Color(0xFF22202A); // Fallback
  static const Color darkSurfaceContainerHigh = Color(0xFF2A2933);
  static const Color darkSurfaceContainerHighest = Color(0xFF33313E); // Fallback
  static const Color darkSurfaceBright = Color(0xFF3A3842);
  
  static const Color darkPrimary = Color(0xFFC4C0FF);
  static const Color darkPrimaryContainer = Color(0xFF8781FF);
  static const Color darkOnPrimaryFixed = Color(0xFF100069);
  static const Color darkPrimaryFixed = Color(0xFFE3DFFF);
  
  static const Color darkSecondary = Color(0xFF41EEC2);
  static const Color darkSecondaryFixedDim = Color(0xFF28DFB5); // Success tone
  
  static const Color darkTertiaryContainer = Color(0xFFF16161); // Error fill
  static const Color darkOnTertiaryContainer = Color(0xFFFFFFFF); // Error text
  
  static const Color darkOnSurface = Color(0xFFFAFAFA);
  static const Color darkOutlineVariant = Color(0x26FFFFFF); // 15% opacity ghost border

  // Light Theme
  static const Color lightPrimary = Color(0xFF4D41DF);
  static const Color lightPrimaryContainer = Color(0xFF675DF9);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  
  static const Color lightSecondary = Color(0xFF006B55);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  
  static const Color lightTertiary = Color(0xFF1A1A2E);
  
  static const Color lightBackground = Color(0xFFF9F9FF);
  static const Color lightSurface = Color(0xFFF9F9FF);
  
  static const Color lightSurfaceContainerLow = Color(0xFFF3F3FA);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFEEEEF5); // Fallback
  static const Color lightSurfaceContainerHigh = Color(0xFFE7E8EE);
  static const Color lightSurfaceContainerHighest = Color(0xFFE0E1E8); // Fallback
  
  static const Color lightOnSurface = Color(0xFF1A1A2E); // Deep navy
  static const Color lightOnSurfaceVariant = Color(0xFF464555);
  
  static const Color lightOutlineVariant = Color(0xFFC7C4D8);
  static const Color transparent = Colors.transparent;

  // Semantic
  static const Color success = Color(0xFF28DFB5);
  static const Color error = Color(0xFFF16161);
}
