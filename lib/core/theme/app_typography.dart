import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography styles matching DESIGN_SYSTEM.md
/// All sizes, weights, and letter spacing are exact
class AppTypography {
  // Base font family
  static TextStyle get _baseStyle => GoogleFonts.inter();

  // DISPLAY (Hero moments)
  static TextStyle get dayCounter => _baseStyle.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.02 * 72,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  static TextStyle get levelNumber => _baseStyle.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 48,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  // HEADINGS
  static TextStyle get h1 => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 32,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h2 => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.005 * 24,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h3 => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get h4 => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // BODY
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyDefault => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get caption => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.005 * 12,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // SPECIAL
  static TextStyle get buttonText => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.005 * 16,
        color: AppColors.textOnColor,
        height: 1.0,
      );

  static TextStyle get tabLabel => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: AppColors.textSecondary,
        height: 1.0,
      );

  static TextStyle get badgeText => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.005 * 12,
        color: AppColors.textOnColor,
        height: 1.0,
      );

  static TextStyle get xpDisplay => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: AppColors.xpGold,
        height: 1.0,
      );
}
