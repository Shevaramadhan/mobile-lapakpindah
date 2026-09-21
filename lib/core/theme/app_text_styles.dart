import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapakpindah/core/theme/app_colors.dart';

/// Design token tipografi LapakPindah — font Poppins.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1({
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        letterSpacing: -0.6,
        color: color,
      );

  static TextStyle heading2({
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 26 / 20,
        color: color,
      );

  static TextStyle heading3({
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 34 / 28,
        letterSpacing: -0.7,
        color: color,
      );

  static TextStyle titleLarge({
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        letterSpacing: -0.45,
        color: color,
      );

  static TextStyle titleSmall({
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 20 / 15,
        color: color,
      );

  static TextStyle bodyMedium({
    Color color = AppColors.textSecondary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: color,
      );

  static TextStyle bodySmall({
    Color color = AppColors.textSecondary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: color,
      );

  static TextStyle labelMedium({
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        color: color,
      );

  static TextStyle labelSmall({
    Color color = AppColors.textSecondary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 14 / 11,
        color: color,
      );

  static TextStyle inputText({
    Color color = AppColors.inputPlaceholder,
  }) =>
      GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 20 / 16,
        color: color,
      );

  static TextStyle buttonText({
    Color color = AppColors.onPrimary,
  }) =>
      GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 20 / 15,
        color: color,
      );
}
