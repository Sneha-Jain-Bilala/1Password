import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Base text theme using Inter
  static TextTheme get textTheme => GoogleFonts.interTextTheme();

  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 56, // 3.5rem
    fontWeight: FontWeight.w600,
    letterSpacing: -0.02 * 56,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.02 * 45,
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.02 * 36,
  );

  static TextStyle get headlineLarge =>
      GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600);

  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 28, // 1.75rem
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleLarge =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 16, height: 1.5);

  static TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14, height: 1.5);

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12, // 0.75rem
    height: 1.5,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05 * 14,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12, // 0.75rem
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05 * 12,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05 * 11,
  );
}
