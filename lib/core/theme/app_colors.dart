import 'package:flutter/material.dart';

/// Design System Colors - Day1 App
/// All colors match DESIGN_SYSTEM.md exactly
sealed class AppColors {
  // BACKGROUNDS
  static const Color backgroundPrimary = Color(0xFF0F0F0F);
  static const Color backgroundCard = Color(0xFF1A1A1A);
  static const Color backgroundSurface = Color(0xFF262626);
  static const Color backgroundElevated = Color(0xFF2D2D2D);

  // PRIMARY BRAND
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // CATEGORY COLORS (The 4 Wins)
  static const Color physical = Color(0xFF3B82F6); // Blue
  static const Color mental = Color(0xFF8B5CF6); // Purple
  static const Color creative = Color(0xFFF97316); // Orange
  static const Color growth = Color(0xFF22C55E); // Green

  // GAMIFICATION
  static const Color xpGold = Color(0xFFF59E0B);
  static const Color streakFire = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color levelPurple = Color(0xFFA855F7);

  // TEXT
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textTertiary = Color(0xFF737373);
  static const Color textOnColor = Color(0xFFFFFFFF);

  // BORDERS & DIVIDERS
  static const Color borderDefault = Color(0xFF333333);
  static const Color borderSubtle = Color(0xFF262626);
  static const Color divider = Color(0xFF1F1F1F);
}
