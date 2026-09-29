import 'package:flutter/material.dart';

/// Design token warna LapakPindah — diekstrak dari Figma.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFB15F00);
  static const Color primaryDark = Color(0xFF8D4B00);
  static const Color onPrimary = Color(0xFFFFFBFF);

  // Text
  static const Color textPrimary = Color(0xFF111C2D);
  static const Color textSecondary = Color(0xFF565E74);

  // Input
  static const Color inputIcon = Color(0xFF887364);
  static const Color inputBorder = Color(0xFFDBC2B0);
  static const Color inputPlaceholder = Color(0xB3887364); // rgba(136,115,100,0.7)

  // Surface
  static const Color surfaceBackground = Color(0xFFF9F9FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceChip = Color(0xFFF0F3FF);

  // Semantic
  static const Color success = Color(0xFF006948);
  static const Color error = Color(0xFFBA1A1A);

  // Accent
  static const Color accentLight = Color(0xFFFFDCC3);

  // Shadow
  static const Color shadow = Color(0x33000000); // rgba(0,0,0,0.2)
  static const Color shadowCard = Color(0x40000000); // rgba(0,0,0,0.25)
}
