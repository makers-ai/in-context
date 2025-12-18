import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary color from design reference
  static const Color primary = Color(0xFF2a6aea);

  // Background colors
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF111621);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1a202e);

  // Text colors
  static const Color textMainLight = Color(0xFF1F2937); // gray-900
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textMutedLight = Color(0xFF6B7280); // gray-500
  static const Color textMutedDark = Color(0xFF9CA3AF); // gray-400

  // Semantic colors (keep existing, add some new ones)
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6); // blue-500

  // Accent colors for prompt cards (from HTML examples)
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentOrange = Color(0xFFF97316);

  // Neutral colors (keep existing grays for compatibility)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
}
